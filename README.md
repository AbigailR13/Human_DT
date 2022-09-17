# Human_DT
Human digital twin for prediction of physiological states

***MAKE SURE THE MAIN FOLDER IS CALLED 'Human_DT'***

***PLEASE RUN add_all_files_to_path_script.m FIRST TO MAKE SURE ALL FILES ARE IN PATH***

All data can be found in Data folder

get_SVM_model_script.m can be run to train an SVM model (requires Deep Learning Toolbox and Statistics and Machine Learning Toolbox)

Human_DT_script.m can be run to run the physiological state human digital twin on testing data (requires Deep Learning Toolbox and Statistics and Machine Learning Toolbox). The human DT will output physiological states, quality-of-output metrics, and the percent of correctly labeled physiological states for each 20 second interval of testing data.
