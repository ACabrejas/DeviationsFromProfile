# Clear-all
rm(list = ls())

# Gaussian filter weights
w1 <- pnorm(-2.5)
w2 <- diff(pnorm(-2.5:-1.5))
w3 <- diff(pnorm(-1.5:-0.5))
w4 <- diff(pnorm(-0.5:0.5))
w5 <- w3
w6 <- w2
w7 <- w1

# Load random data
data <- read.csv('m25_data.csv')
flow <- data$Flow
flow <- flow / 60 # Transform form vehicles/hour to vehicles/minute
speed <- data$Speed

# Filter data of whole day
flow_filtered <- rep(0, length(flow))
speed_filtered <- rep(0, length(speed))
for (i in 4:(length(flow)-3)) {
  flow_filtered[i] <- w1*flow[i-3] + w2*flow[i-2] + w3*flow[i-1] + w4*flow[i] + w5*flow[i+1] + w6*flow[i+2] + w7*flow[i+3]
  speed_filtered[i] <- w1*speed[i-3] + w2*speed[i-2] + w3*speed[i-1] + w4*speed[i] + w5*speed[i+1] + w6*speed[i+2] + w7*speed[i+3]
}

# Plot data of whole day (no filter)
plot(flow,speed,col='red',xlab ="flow (vehicles/minute)",ylab ="speed (km/hour)")
lines(flow,speed,col='red')

# Plot filtered data of whole day
plot(flow_filtered,speed_filtered,col='red',xlab ="flow (vehicles/minute)",ylab ="speed (km/hour)")
lines(flow_filtered,speed_filtered,col='red')

# Plot flow and speed as a function of time
time <- seq(1, length(flow))
plot(time,flow,xlab="time (minutes)",ylab ="flow (vehicles/minute)")
plot(time,speed,xlab="time (minutes)",ylab ="speed (km/hour)")

# -----Find congestion events
# Build regime column
regime <- rep(0, length(flow_filtered))
for (j in 1:length(flow_filtered)) {
  if ( (speed_filtered[j] < 16*flow_filtered[j]) & (speed_filtered[j] < -(2/3)*flow_filtered[j] + 95) ) {
    regime[j] = 1
  }
}

# Separate events
counter <- 0
number <- rep(0, length(flow_filtered))
for (j in 1:length(flow_filtered)) {
  if (j ==1 & regime[j]==1) {
    counter = counter + 1
  }
  if (j>=2) {
    if (regime[j]==1 & regime[j-1]==0) {
      counter = counter + 1
    }
  } 
  number[j] = counter
}
#plot(time,regime,xlab="time (minutes)",ylab ="regime")

# Plot first traffic jam 
tj_1_flow <- flow_filtered[504:630]
tj_1_speed <- speed_filtered[504:630]
tj_1_int <- rep(0, length(tj_1_flow))
for (k in 1:length(tj_1_flow)) {
  #tj_1_int[k] = abs(16*tj_1_flow[k] -1*tj_1_speed[k])/sqrt(256+1)
  tj_1_int[k] = sqrt(abs(tj_1_flow[k]-tj_1_flow[1])^2 + abs(tj_1_speed[k]-tj_1_speed[1])^2)
}
time_tj_1 = seq(1, length(tj_1_int))
plot(time_tj_1,tj_1_int,col='blue',xlab="time (minutes)",ylab ="traffic jam #1 intensity")
lines(time_tj_1,tj_1_int,col='blue')

# Plot second traffic jam
tj_2_flow <- flow_filtered[1003:1075]
tj_2_speed <- speed_filtered[1003:1075]
tj_2_int <- rep(0, length(tj_2_flow))
for (k in 1:length(tj_2_flow)) {
  tj_2_int[k] = sqrt(abs(tj_2_flow[k]-tj_2_flow[1])^2 + abs(tj_2_speed[k]-tj_2_speed[1])^2)
}
time_tj_2 = seq(1, length(tj_2_int))
plot(time_tj_2,tj_2_int,col='blue',xlab="time (minutes)",ylab ="traffic jam #2 intensity")
lines(time_tj_2,tj_2_int,col='blue')





