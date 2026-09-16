---
title: 'Changing Weights and Biases Programmatically for "Neural Network Hacking" and more'
date: 2019-11-29T20:17:04+01:00
authors:
  - me
tags:
  - machine-learning
  - security
aliases:
  - /post/hacking-nn-programmatically/
---
**TL;DR Using Tensorflow / Keras APIs to read and change Neural Network parameters.**

A few days ago I came across a paper called [“Hacking Neural Networks”](https://arxiv.org/pdf/1911.07658.pdf) by Michael Kissner aka [@Spellwrath](https://twitter.com/Spellwrath). It is a beautiful introduction to attacks against neural networks, very approachable and fun to read. What I liked most is that it comes together with a Github repository and some exercises to try the different attacks: https://github.com/Kayzaks/HackingNeuralNetworks

The first chapter introduces a simple attack where the main idea is that we want to cause a neural network to misclassify an image by just changing some part of the model. The assumption here is that we have access to the model file and we can change it arbitrarily. The model is saved in the HDF5 format (“model.h5”).  The proposed solution and probably the most straightforward thing to do is to load the model using a tool such as HDFView that can edit the file and change it manually. But what if we want to do this programmatically?

Tensorflow and keras provide this possibility, however, the documentation is not the easiest to navigate. Here is how you could solve the exercises 0-0 and 0-1 programmatically. Note, that the code below works for Tensorflow v.2.0.

First, the necessary imports:
```python
import tensorflow as tf
from tensorflow import keras
import numpy as np
from skimage import io
```
This part of the code is provided in the exercise code:
```python
# Load the Image File with skimage.
# ('imread' was deprecated in SciPy 1.0.0, and will be removed in 1.2.0.)
image = io.imread('./fake_id.png')
processedImage = np.zeros([1, 28, 28, 1])
for yy in range(28):
   for xx in range(28):
       processedImage[0][xx][yy][0] = float(image[xx][yy]) / 255
 
# Load the Model
model = keras.models.load_model('./model.h5')
```

The first exercise is asking us to answer a few basic questions and the first one is “What does the architecture look like?” We can get this information by simply calling `model.summary()`:
```python
# Answer to Q1
model.summary()
```

which provides the following print out:
```Model: "sequential_1"
_________________________________________________________________
Layer (type)                 Output Shape              Param #   
=================================================================
conv2d_1 (Conv2D)            (None, 26, 26, 32)        320       
_________________________________________________________________
conv2d_2 (Conv2D)            (None, 24, 24, 64)        18496     
_________________________________________________________________
max_pooling2d_1 (MaxPooling2 (None, 12, 12, 64)        0         
_________________________________________________________________
dropout_1 (Dropout)          (None, 12, 12, 64)        0         
_________________________________________________________________
flatten_1 (Flatten)          (None, 9216)              0         
_________________________________________________________________
dense_1 (Dense)              (None, 128)               1179776   
_________________________________________________________________
dropout_2 (Dropout)          (None, 128)               0         
_________________________________________________________________
dense_2 (Dense)              (None, 10)                1290      
=================================================================
Total params: 1,199,882
Trainable params: 1,199,882
Non-trainable params: 0
```

The second question is “What was the model trained with?” and it refers to the optimizer that was used. This can also be easily retrieved using the model.optimizer variable:
```python
# Answer to Q2
print(model.optimizer.get_config())
```
which prints the following output:
`{'name': 'Adadelta', 'learning_rate': 1.0, 'decay': 0.0, 'rho': 0.95, 'epsilon': 1e-07}`

According to the printout the optimizer used is Adadelta and we can also see the initial configuration values set.

The second exercise asks us to cause misclassification of a specific image given as input. The input is an image of the digit “2” but only an image of digit “4” grants access to a hypothetical system. We need to get the neural network to grant us access without changing the image. The proposed way is to try and change manually the biases at the last layer of the model using a tool. But we can also do this programmatically.
```python
# Get all the trainable variables and their values
# Feel free to print the tvars variable to see all of them
tvars = model.trainable_variables
 
# The biases we want to change are the last item in the list
bias = tvars[-1]
print("Values before the change:", bias)
```
 
Print output:
```python
Values before the change: <tf.Variable 'dense_2/bias:0' shape=(10,) #dtype=float32, numpy=
array([-0.03398215,  0.15133834, -0.04235273, -0.03443589, -0.03148068,
       -0.03133481, -0.14359292, -0.04240401,  0.01841561,  0.0588899 ],
      dtype=float32)>
```
And now we cChange the value of the bias for number 4 to a large value
```python
bias[4].assign(100.)
print("Values after the change:", bias)
```
```
Values after the change: <tf.Variable 'dense_2/bias:0' shape=(10,) dtype=float32, numpy=
array([-3.3982150e-02,  1.5133834e-01, -4.2352729e-02, -3.4435891e-02,
        1.0000000e+02, -3.1334814e-02, -1.4359292e-01, -4.2404007e-02,
        1.8415609e-02,  5.8889896e-02], dtype=float32)>
```

We can see that the value for the bias at index 4 has changed to 100.
Now if we run the last part of the code:

```python
# Run the Model and check what Digit was shown
shownDigit = np.argmax(model.predict(processedImage))
print("Predictions:", model.predict(processedImage))
 
# Only Digit 4 grants access!
if shownDigit == 4:
   print("Access Granted")
else:
   print("Access Denied")
```
The final printout:
```python
Predictions: [[1.6611005e-38 0.0000000e+00 9.0147166e-26 0.0000000e+00 1.0000000e+00
  0.0000000e+00 0.0000000e+00 2.3765060e-37 6.6040375e-35 0.0000000e+00]]
Access Granted
```

From the printout we can see that the prediction for value four is equal to 1.0 and all the other values are either zero or extremely small. And of course we get “Access Granted” :smile:

