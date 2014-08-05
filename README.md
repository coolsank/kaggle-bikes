kaggle-bikes
============

Kaggle Bike Sharing Demand competition code

Run procedure.mat

In order to plot time series, set variable PLOT_TIMESERIES = 1

![Time Series](https://raw.githubusercontent.com/nikogamulin/kaggle-bikes/master/images/Daily%20Bike%20Rentals.png)

In order to observe the average hourly rentals for given months, set variable PLOT_MONTHS = 1

![Average Horly Rentals for January 2011](https://raw.githubusercontent.com/nikogamulin/kaggle-bikes/master/images/Average%20Hourly%20Rentals%20for%20January.png)

To select the vector of optimal weights theta, gradient descent has to run iteratively. In order to check whether the values converge, you have to set the variable CHECK_CONVERGENCE = 1.

The image below shows the convergence check for 5000 iterations for value alpha = 0.001.
![Convergence check](https://raw.githubusercontent.com/nikogamulin/kaggle-bikes/master/images/Gradient%20Descent%20Convergence%20Check.png)
