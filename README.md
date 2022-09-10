# Human_DT
Human digital twin for  prediction physiological states

Training data can be found in Training Data folder

Testing data can be found in Testing Data folder

get_SVM_model_script can be run to train an SVM model using the training data (requires deep learning toolbox)

get_qofm_distribution_script can be run to get a quality-of-output metric (prbobability that a physiological state was correctly classified) distribution using testing data

Human_DT_script can be run to run the physiological state human digital twin on testing data. The human DT will output physiological states, quality-of-output metrics, and the percent of correctly labeled physiological states for each 20 second interval of testing data.   
