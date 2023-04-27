"""Loads LogisticRegression SciKit-Learn model"""
import pickle5 as pickle

model = pickle.load(open('model-files/balanced_log_reg_model.pkl', 'rb'))

x = [ 1,1,1,1,1,1,0,0,1,0,1,0,1,0,1,0,1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,1,1,0,0,0,0 ]
# Use model to predict data
result = model.predict( [x] ) # Passing x between brackets b/c model.predict receives a list of arrays/or a 2D array
print(f"Prediction finished correctly")
print(f"Model predicted the class: {result}")
