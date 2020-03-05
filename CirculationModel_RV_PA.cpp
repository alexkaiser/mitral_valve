// Filename: CirculationModel_RV_PA.cpp
// Created on 20 Aug 2007 by Boyce Griffith

// Modified 2019, Alexander D. Kaiser

#include "CirculationModel_RV_PA.h"

/////////////////////////////// INCLUDES /////////////////////////////////////

#ifndef included_IBAMR_config
#include <IBAMR_config.h>
#define included_IBAMR_config
#endif

#ifndef included_SAMRAI_config
#include <SAMRAI_config.h>
#define included_SAMRAI_config
#endif

// SAMRAI INCLUDES
#include <CartesianGridGeometry.h>
#include <CartesianPatchGeometry.h>
#include <PatchLevel.h>
#include <SideData.h>
#include <tbox/RestartManager.h>
#include <tbox/SAMRAI_MPI.h>
#include <tbox/Utilities.h>

// C++ STDLIB INCLUDES
#include <cassert>

#include <Eigen/Dense>
using namespace Eigen;

namespace
{
// Name of output file.
static const string DATA_FILE_NAME = "bc_data.m";

} 

/////////////////////////////// NAMESPACE ////////////////////////////////////

/////////////////////////////// STATIC ///////////////////////////////////////

int pnpoly(int nvert, double *vertx, double *verty, double testx, double testy){

    // Source: https://wrf.ecse.rpi.edu//Research/Short_Notes/pnpoly.html
    // modified here for double precision 

    // Copyright (c) 1970-2003, Wm. Randolph Franklin
    //
    // Permission is hereby granted, free of charge, to any person obtaining a copy of 
    // this software and associated documentation files (the "Software"), to deal in 
    // the Software without restriction, including without limitation the rights to use, 
    // copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
    // Software, and to permit persons to whom the Software is furnished to do so, 
    // subject to the following conditions:
    //
    //
    // 1. Redistributions of source code must retain the above copyright notice, 
    // this list of conditions and the following disclaimers.
    // 2. Redistributions in binary form must reproduce the above copyright notice 
    // in the documentation and/or other materials provided with the distribution.
    // 3. The name of W. Randolph Franklin may not be used to endorse or promote 
    // products derived from this Software without specific prior written permission.
    //
    //
    // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
    // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
    // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
    // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
    // WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
    // IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    int i, j, c = 0;
    for (i = 0, j = nvert-1; i < nvert; j = i++) {
        if ( ((verty[i]>testy) != (verty[j]>testy)) &&
             (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
            c = !c;
    }
    return c;
}


/////////////////////////////// PUBLIC ///////////////////////////////////////

CirculationModel_RV_PA::CirculationModel_RV_PA(const fourier_series_data *fourier_right_ventricle, 
                                                   const fourier_series_data *fourier_right_pa, 
                                                   const fourier_series_data *fourier_left_pa, 
                                                   string right_ventricle_vertices_file_name,
                                                   string right_pa_vertices_file_name,
                                                   string left_pa_vertices_file_name,
                                                   const double  cycle_duration,
                                                   const double  t_offset_bcs_unscaled, 
                                                   const double  initial_time)
    : 
      d_object_name("circ_model_with_lv"),  // constant name here  
      d_registered_for_restart(true),      // always true
      d_fourier_right_ventricle(fourier_right_ventricle), 
      d_fourier_right_pa(fourier_right_pa),       
      d_fourier_left_pa(fourier_left_pa), 
      d_cycle_duration(cycle_duration),
      d_t_offset_bcs_unscaled(t_offset_bcs_unscaled),
      d_current_idx_series(0),
      d_Q_right_ventricle(0.0), 
      d_Q_right_pa       (0.0),
      d_Q_left_pa        (0.0),
      d_time(initial_time), 
      d_area_right_ventricle(0.0),
      d_area_right_pa(0.0),
      d_area_left_pa (0.0),
      d_area_initialized(false)
{
    
    if (d_registered_for_restart)
    {
        RestartManager::getManager()->registerRestartItem(d_object_name, this);
    }

    // Initialize object with data read from the input and restart databases.
    const bool from_restart = RestartManager::getManager()->isFromRestart();
    if (from_restart)
    {
        getFromRestart();
    }
    
    double x,x_prev,y,y_prev,z,z_prev; 
    double tol = 1.0e-2; 

    // read vertices from file 
    ifstream right_ventricle_file(right_ventricle_vertices_file_name.c_str(), ios::in);

    if(!right_ventricle_file){
        TBOX_ERROR("Aorta file not found\n"); 
    }

    right_ventricle_file >> d_n_pts_right_ventricle; 
    
    d_right_ventricle_points_idx1 = new double[d_n_pts_right_ventricle]; 
    d_right_ventricle_points_idx2 = new double[d_n_pts_right_ventricle]; 

    for (int i=0; i<d_n_pts_right_ventricle; i++){
        right_ventricle_file >> x; 
        right_ventricle_file >> d_right_ventricle_points_idx1[i]; 
        right_ventricle_file >> d_right_ventricle_points_idx2[i];
        
        if (i>0){
            if (fabs(x_prev - x) > tol){
                TBOX_ERROR("Z coordinates must be consistent\n"); 
            }
        }
        x_prev = x; 

    }
    pout << "to right_ventricle file close\n"; 
    right_ventricle_file.close(); 
    d_right_ventricle_axis = 0; 
    d_right_ventricle_side = 0; 

    // read vertices from file 
    ifstream right_pa_file(right_pa_vertices_file_name.c_str(), ios::in);

    if(!right_pa_file){
        TBOX_ERROR("Aorta file not found\n"); 
    }

    right_pa_file >> d_n_pts_right_pa; 
    
    d_right_pa_points_idx1 = new double[d_n_pts_right_pa]; 
    d_right_pa_points_idx2 = new double[d_n_pts_right_pa]; 

    for (int i=0; i<d_n_pts_right_pa; i++){
        right_pa_file >> d_right_pa_points_idx1[i]; 
        right_pa_file >> y; 
        right_pa_file >> d_right_pa_points_idx2[i];
        

        if (i>0){
            if (fabs(y_prev - y) > tol){
                TBOX_ERROR("Z coordinates must be consistent\n"); 
            }
        }
        y_prev = y; 

    }
    pout << "to right_pa file close\n"; 
    right_pa_file.close(); 
    d_right_pa_axis = 1; 
    d_right_pa_side = 0; 

    // read vertices from file 
    ifstream left_pa_file(left_pa_vertices_file_name.c_str(), ios::in);

    if(!left_pa_file){
        TBOX_ERROR("Aorta file not found\n"); 
    }

    left_pa_file >> d_n_pts_left_pa; 
    
    d_left_pa_points_idx1 = new double[d_n_pts_left_pa]; 
    d_left_pa_points_idx2 = new double[d_n_pts_left_pa]; 

    for (int i=0; i<d_n_pts_left_pa; i++){
        left_pa_file >> d_left_pa_points_idx1[i]; 
        left_pa_file >> d_left_pa_points_idx2[i];
        left_pa_file >> z; 

        if (i>0){
            if (fabs(z_prev - z) > tol){
                TBOX_ERROR("Z coordinates must be consistent\n"); 
            }
        }
        z_prev = z; 

    }
    pout << "to left_pa file close\n"; 
    left_pa_file.close();
    d_left_pa_axis = 2; 
    d_left_pa_side = 0; 

    pout << "passed contstructor\n"; 

    return;
} // CirculationModel

CirculationModel_RV_PA::~CirculationModel_RV_PA()
{
    return;
} // ~CirculationModel_RV_PA


void CirculationModel_RV_PA::advanceTimeDependentData(const double dt,
                                                        const Pointer<PatchHierarchy<NDIM> > hierarchy,
                                                        const int U_idx,
                                                        const int /*P_idx*/,
                                                        const int /*wgt_cc_idx*/,
                                                        const int wgt_sc_idx)
{
    // Compute the mean flow rates in the vicinity of the inflow and outflow
    // boundaries.
    
    double Q_right_ventricle_local = 0.0; 
    double Q_right_pa_local = 0.0; 
    double Q_left_pa_local = 0.0; 

    double area_right_ventricle_local = 0.0; 
    double area_right_pa_local = 0.0; 
    double area_left_pa_local = 0.0; 

    for (int ln = 0; ln <= hierarchy->getFinestLevelNumber(); ++ln)
    {
        Pointer<PatchLevel<NDIM> > level = hierarchy->getPatchLevel(ln);
        for (PatchLevel<NDIM>::Iterator p(level); p; p++)
        {
            Pointer<Patch<NDIM> > patch = level->getPatch(p());
            Pointer<CartesianPatchGeometry<NDIM> > pgeom = patch->getPatchGeometry();
            if (pgeom->getTouchesRegularBoundary())
            {
                Pointer<SideData<NDIM, double> > U_data = patch->getPatchData(U_idx);
                Pointer<SideData<NDIM, double> > wgt_sc_data = patch->getPatchData(wgt_sc_idx);
                const Box<NDIM>& patch_box = patch->getBox();
                const double* const x_lower = pgeom->getXLower();
                const double* const dx = pgeom->getDx();
                double dV = 1.0;
                for (int d = 0; d < NDIM; ++d)
                {
                    dV *= dx[d];
                }

                for(int axis=0; axis<3; axis++)
                {
                    for(int side=0; side<2; side++)
                    {
                        const bool is_lower = (side == 0);
                        if (pgeom->getTouchesRegularBoundary(axis, side))
                        {
                            
                            Vector n;
                            for (int d = 0; d < NDIM; ++d)
                            {
                                n[d] = axis == d ? (is_lower ? -1.0 : +1.0) : 0.0;
                            }
                            Box<NDIM> side_box = patch_box;
                            if (is_lower)
                            {
                                side_box.lower(axis) = patch_box.lower(axis);
                                side_box.upper(axis) = patch_box.lower(axis);
                            }
                            else
                            {
                                side_box.lower(axis) = patch_box.upper(axis) + 1;
                                side_box.upper(axis) = patch_box.upper(axis) + 1;
                            }
                            for (Box<NDIM>::Iterator b(side_box); b; b++)
                            {
                                const Index<NDIM>& i = b();

                                double X[NDIM];
                                for (int d = 0; d < NDIM; ++d)
                                {
                                    X[d] = x_lower[d] + dx[d] * (double(i(d) - patch_box.lower(d)) + (d == axis ? 0.0 : 0.5));
                                }

                                double X_in_plane_1; 
                                double X_in_plane_2; 
                                if (axis == 0)
                                {
                                    X_in_plane_1 = X[1]; 
                                    X_in_plane_2 = X[2]; 
                                }
                                else if (axis == 1)
                                {
                                    X_in_plane_1 = X[0]; 
                                    X_in_plane_2 = X[2]; 
                                }
                                else if (axis == 2)
                                {
                                    X_in_plane_1 = X[0]; 
                                    X_in_plane_2 = X[1]; 
                                }

                                const int in_right_ventricle  = this->point_in_right_ventricle(X_in_plane_1, X_in_plane_2, axis, side);
                                const int in_right_pa         = this->point_in_right_pa       (X_in_plane_1, X_in_plane_2, axis, side);
                                const int in_left_pa          = this->point_in_left_pa        (X_in_plane_1, X_in_plane_2, axis, side);

                                if (in_right_ventricle && in_right_pa){
                                    TBOX_ERROR("Position is within two inlets and outlets, should be impossible\n"); 
                                }
                                if (in_right_ventricle && in_left_pa){
                                    TBOX_ERROR("Position is within two inlets and outlets, should be impossible\n"); 
                                }
                                if (in_right_pa && in_left_pa){
                                    TBOX_ERROR("Position is within two inlets and outlets, should be impossible\n"); 
                                }

                                if (in_right_ventricle)
                                {
                                    const SideIndex<NDIM> i_s(i, axis, SideIndex<NDIM>::Lower);
                                    if ((*wgt_sc_data)(i_s) > std::numeric_limits<double>::epsilon())
                                    {
                                        double dA = n[axis] * dV / dx[axis];
                                        Q_right_ventricle_local += (*U_data)(i_s)*dA;

                                        if (!d_area_initialized){
                                            area_right_ventricle_local += dA;
                                        }

                                    }
                                }

                                if (in_right_pa)
                                {
                                    const SideIndex<NDIM> i_s(i, axis, SideIndex<NDIM>::Lower);
                                    if ((*wgt_sc_data)(i_s) > std::numeric_limits<double>::epsilon())
                                    {
                                        double dA = n[axis] * dV / dx[axis];
                                        Q_right_pa_local += (*U_data)(i_s)*dA;

                                        if (!d_area_initialized){
                                            area_right_pa_local += dA;
                                        }

                                    }
                                }

                                if (in_left_pa)
                                {
                                    const SideIndex<NDIM> i_s(i, axis, SideIndex<NDIM>::Lower);
                                    if ((*wgt_sc_data)(i_s) > std::numeric_limits<double>::epsilon())
                                    {
                                        double dA = n[axis] * dV / dx[axis];
                                        Q_left_pa_local += (*U_data)(i_s)*dA;

                                        if (!d_area_initialized){
                                            area_left_pa_local += dA;
                                        }

                                    }
                                }

                            }
                        }
                    }
                }
            }
        }
    }

    d_Q_right_ventricle = SAMRAI_MPI::sumReduction(Q_right_ventricle_local);
    d_Q_right_pa        = SAMRAI_MPI::sumReduction(Q_right_pa_local);
    d_Q_left_pa         = SAMRAI_MPI::sumReduction(Q_left_pa_local);

    if (!d_area_initialized){
        d_area_right_ventricle = SAMRAI_MPI::sumReduction(area_right_ventricle_local);
        d_area_right_pa        = SAMRAI_MPI::sumReduction(area_right_pa_local);  
        d_area_left_pa         = SAMRAI_MPI::sumReduction(area_left_pa_local);  
        d_area_initialized = true;       
    }

    d_time += dt; 

    // compute which index in the Fourier series we need here 
    // always use a time in current cycle 
    double t_reduced = d_time - d_cycle_duration * floor(d_time/d_cycle_duration); 

    // fourier series has its own period, scale to that 
    double t_scaled = t_reduced * (d_fourier_right_ventricle->L  / d_cycle_duration); 

    // start offset some arbitrary time in the cardiac cycle, but this is relative to the series length 
    double t_scaled_offset = t_scaled + d_t_offset_bcs_unscaled; 

    // Fourier data here
    // index without periodicity 
    unsigned int k = (unsigned int) floor(t_scaled_offset / (d_fourier_right_ventricle->dt));
    
    // // take periodic reduction
    d_current_idx_series = k % (d_fourier_right_ventricle->N_times);

    // bool debug_out = false; 
    // if (debug_out){
    //     pout << "circ mode: d_time = " << d_time << ", d_current_idx_series = " << d_current_idx_series << "\n"; 
    //     pout << "t_reduced = " << t_reduced << " t_scaled = " << t_scaled << " t_scaled_offset = " << t_scaled_offset << "\n"; 
    //     pout << "k (unreduced idx) = " << k << " d_current_idx_series = " << d_current_idx_series << "\n\n"; 
    // }


    writeDataFile(); 

} // advanceTimeDependentData

void CirculationModel_RV_PA::set_Q_valve(double Q_valve){
    d_Q_valve = Q_valve; 
}


void
CirculationModel_RV_PA::putToDatabase(Pointer<Database> db)
{

    db->putInteger("d_current_idx_series", d_current_idx_series); 
    db->putDouble("d_Q_right_ventricle", d_Q_right_ventricle); 
    db->putDouble("d_Q_right_pa", d_Q_right_pa);
    db->putDouble("d_Q_left_pa", d_Q_left_pa);
    db->putDouble("d_Q_valve", d_Q_valve);
    db->putDouble("d_time", d_time); 
    return; 
} // putToDatabase

void CirculationModel_RV_PA::print_summary(){

    double P_right_ventricle = d_fourier_right_ventricle->values[d_current_idx_series]; 
    double P_right_pa        = d_fourier_right_pa->values[d_current_idx_series];
    double P_left_pa         = d_fourier_left_pa->values[d_current_idx_series];

    pout << "% time \t P_right_ventricle (mmHg)\t P_right_pa (mmHg)\t P_left_pa (mmHg)\t Q_right_ventricle (ml/s)\t d_Q_right_pa (ml/s)\t d_Q_right_pa (ml/s)\tQ_valve (ml/s) \t idx\n" ; 
    pout << d_time << " " << P_right_ventricle <<  " " << P_right_pa << " " << P_left_pa << " " << d_Q_right_ventricle << " " << d_Q_right_pa << " " << d_Q_left_pa << " " << d_Q_valve << " " << d_current_idx_series << "\n";    

}

int CirculationModel_RV_PA::point_in_right_ventricle(double testx, double testy, int axis, int side){
    // checks whether given point is in right ventricle

    // quick exit for correct side and axis 
    if ((axis != d_right_ventricle_axis) || (side != d_right_ventricle_side))
        return 0; 

    return pnpoly(d_n_pts_right_ventricle, d_right_ventricle_points_idx1, d_right_ventricle_points_idx2, testx, testy); 
}

int CirculationModel_RV_PA::point_in_right_pa(double testx, double testy, int axis, int side){
    // checks whether given point is in right ventricle

    // quick exit for correct side and axis 
    if ((axis != d_right_pa_axis) || (side != d_right_pa_side))
        return 0; 

    return pnpoly(d_n_pts_right_pa, d_right_pa_points_idx1, d_right_pa_points_idx2, testx, testy); 
}

int CirculationModel_RV_PA::point_in_left_pa(double testx, double testy, int axis, int side){
    // checks whether given point is in right ventricle

    // quick exit for correct side and axis 
    if ((axis != d_left_pa_axis) || (side != d_left_pa_side))
        return 0; 

    return pnpoly(d_n_pts_left_pa, d_left_pa_points_idx1, d_left_pa_points_idx2, testx, testy); 
}

/////////////////////////////// PROTECTED ////////////////////////////////////

/////////////////////////////// PRIVATE //////////////////////////////////////

void
CirculationModel_RV_PA::writeDataFile() const
{
    static const int mpi_root = 0;
    if (SAMRAI_MPI::getRank() == mpi_root)
    {
        static bool file_initialized = false;
        const bool from_restart = RestartManager::getManager()->isFromRestart();
        if (!from_restart && !file_initialized)
        {
            ofstream fout(DATA_FILE_NAME.c_str(), ios::out);
            fout << "% time \t P_aorta (mmHg)\t P_atrium (mmHg)\t P_ventricle (mmHg)\t Q_Aorta (ml/s)\t d_Q_left_atrium (ml/s)\tQ_mitral (ml/s)"
                 << "\n"
                 << "bc_vals = [";
            file_initialized = true;
        }

        ofstream fout(DATA_FILE_NAME.c_str(), ios::app);

        fout << d_time;
        fout.setf(ios_base::scientific);
        fout.setf(ios_base::showpos);
        fout.precision(10);

        double P_right_ventricle = d_fourier_right_ventricle->values[d_current_idx_series]; 
        double P_right_pa        = d_fourier_right_pa->values[d_current_idx_series];
        double P_left_pa         = d_fourier_left_pa->values[d_current_idx_series];
        fout << " " << P_right_ventricle <<  " " << P_right_pa << " " << P_left_pa << " " << d_Q_right_ventricle << " " << d_Q_right_pa << " " << d_Q_left_pa << " " << d_Q_valve << "; \n";

    }

    return;
} // writeDataFile

void
CirculationModel_RV_PA::getFromRestart()
{
    Pointer<Database> restart_db = RestartManager::getManager()->getRootDatabase();
    Pointer<Database> db;
    if (restart_db->isDatabase(d_object_name))
    {
        db = restart_db->getDatabase(d_object_name);
    }
    else
    {
        TBOX_ERROR("Restart database corresponding to " << d_object_name << " not found in restart file.");
    }

    d_current_idx_series = db->getInteger("d_current_idx_series"); 
    d_Q_right_ventricle  = db->getDouble("d_Q_right_ventricle"); 
    d_Q_right_pa         = db->getDouble("d_Q_right_pa");
    d_Q_left_pa          = db->getDouble("d_Q_left_pa");
    d_Q_valve            = db->getDouble("d_Q_valve");
    d_time               = db->getDouble("d_time");

    return;
} // getFromRestart

/////////////////////////////// NAMESPACE ////////////////////////////////////

/////////////////////////////// TEMPLATE INSTANTIATION ///////////////////////

//////////////////////////////////////////////////////////////////////////////