

%% Welcome to the DBSFILT toolbox.

-------------------------------------

A matlab toolbox designed to study the detection and the removal of HF-DBS* artifacts from EEG or MEG data.
*=High Frequency Deep Brain Stimulation.

-------------------------------------

This toolbox provide a set of signal processing function to detect, characterize and remove HF-DBS artefacts.
Please refer to the DBSFILT_GUI_DOC.pdf document for installation.

All useful functions for scripting purposes are located in the fct/ directory.

The DBSFILT_Example_Files directory contain some demonstration scripts and a set of contaminated EEG data for testing :

		DBSFILT_demo.m	 % step by step filtering
		DBSFILT_demo2.m  % direct filtering

		Raw data file : 
		DBSFILT_P1_dbs_ON_EC.set

		Post temporal filtering data file : 
		DBSFILT_P1_dbs_ON_EC_filtered.set

		Post Deep Brain Stimulation (DBS) filtering data file : 
		DBSFILT_P1_dbs_ON_EC_filtered_DBSfiltered.set

		Identified DBS aliased frequencies file : 
		DBSFILT_P1_dbs_ON_EC_filtered_spikelocations.spikes

The DBSFILT_Example_Files/DBSFILT_test_DBSandICA 
and DBSFILT_Example_Files/DBSFILT_test_TimeDomainTemplateSubstraction directories
provide demonstration of some alternative filtering methods that have been not be privileged for reliability purposes. 


Finally, for teaching purposes and an user friendly data exploration, a Graphical User Interface (GUI) was included in the toolbox.
This GUI can be launched with the DBSFILT.m function.

Please refer to the DBSFILT_GUI_DOC.pdf document for a demonstration of DBS artefact filtering via the GUI.

v0.17 - 2016
v0.18 - 2017 - Add dependencies for TimeDomainTemplateSubstraction - DBSFILT_demo3.m.
v0.18b - 2018 - Minor optimizations - Updated documentation 

guillaume.lio@isc.cnrs.fr


    BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
    FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
    OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
    PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
    OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
    TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
    PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
    REPAIR OR CORRECTION.

    IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
    WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
    REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
    INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
    OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
    TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
    YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
    PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGES.

