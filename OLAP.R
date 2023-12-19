#1.

#create date dimension
#For month of October
start_date <- as.Date("2023-10-01")
end_date <- as.Date("2023-10-15")
date <- data.frame(
  date_key = format(seq(start_date, end_date, by = "day"), "%Y%m%d"),
  Date = seq(start_date, end_date, by = "day"),
  Year = format(seq(start_date, end_date, by = "day"), "%Y"),
  Month = format(seq(start_date, end_date, by = "day"), "%m"),
  Month_Name = format(seq(start_date, end_date, by = "day"), "%B"),
  Day = format(seq(start_date, end_date, by = "day"), "%d"),
  Weekday = format(seq(start_date, end_date, by = "day"), "%A")
)


#Setting up the dimension tables


pizza_size <- 
  data.frame(size_key=c("P", "S", "M", "L", "XL"),
             size=c("personal", "small", "medium", "large", "xlarge"),
             price=c(5,15,20,25,30))

topping <- 
  data.frame(topping_key=c("tomatoes", "pepper", "onions", "pepperoni"),
             topping_name=c("tomatoes", "pepper", "onions", "pepperoni"))

cheese <- 
  data.frame(cheese_key=c("swiss", "cheddar", "mozzarella", "parmesan"),
             cheese=c("swiss", "cheddar", "mozzarella", "parmesan"))           

dough <- 
  data.frame(dough_key=c("whole weat thin", "white regular", "stuffed crust", "regular"),
             dough=c("whole weat thin", "white regular", "stuffed crust", "regular"))    

store_location <-
  data.frame(location_key=c("1","2","3","4"),
             address=c("336 Rideau St","458 Rideau St","471 Yonge St", "124 Fulton St"),
             city_key=c("2", "2", "2", "1"))

city <-
  data.frame(city_key = c("1","2"),
             city = c("New York", "Ottawa"),
             country_key = c("1","2"))

country <-
  data.frame(country_key = c("1","2"),
             country = c("United States of America","Canada"),
             province = c("New York","Ontario"),
             region = c("region a", " region b")) 
              

profit <- 
  data.frame(profit_key=c("1", "2", "3"),
             profit=c(22.5, 5.70, 11.20),
             revenue = c(45, 12, 32))

quantity <- c(1,2,3)

str(profit)



# Function to generate the Orders table
gen_orders <- function(no_of_recs) {
  # Generate transaction data randomly
  location_ <- sample(store_location$location_key, no_of_recs, replace=T, prob=c(2,1,1,2))
  order_date_ <- sample(date$date_key, no_of_recs, replace=T)
  order_month_ <- sample(date$Month_Name, no_of_recs, replace=T)
  size_ <- sample(pizza_size$size_key, no_of_recs, replace=T, prob=c(1, 3, 2, 3, 1))
  dough_ <- sample(dough$dough_key, no_of_recs, replace=T, prob=c(1, 3, 1, 3))
  cheese_ <- sample(cheese$cheese_key, no_of_recs, replace=T, prob=c(2, 3, 1, 2))
  topping_ <- sample(topping$topping_key, no_of_recs, replace=T, prob=c(3, 2, 1, 1))
  #profit_ <- sample(profit$profit_key, no_of_recs, replace=T, prob=c(1, 3, 2))
  quantity_ <- sample(quantity, no_of_recs, replace=T, prob=c(3, 2, 1))
  price <- pizza_size$price[match(size_, pizza_size$size_key)]
  revenue <- price * quantity_
  cost_of_sales <- (sample(c(0.8,0.85), no_of_recs, replace=T, prob=c(3, 2))) * revenue
  profit_ <- revenue - cost_of_sales
  

  orders <- data.frame(location_      #= location_,
                       ,order_date_    #= order_date_,
                       ,order_month_
                       ,size_          #= size_,
                       ,dough_         #= dough_,
                       ,cheese_        #= cheese_,
                       ,topping_       #= topping_,
                       #,profit_        #= profit_,
                       ,quantity_       #= quantity
                       ,price
                       ,revenue
                       ,cost_of_sales
                       ,profit_
                       )
  
  # Sort the records by time order
  orders <- orders[order(orders$order_date_),]
  row
  return(orders)
}

# Creating the orders_fact using function
orders_fact <-  gen_orders(500)

# Look at a few records
head(orders_fact)

#----------------------------------------------------------------------
#2. 
  
# Build up a cube for revenue
revenue_cube <- 
  tapply(orders_fact$revenue, 
         orders_fact[,c("size_","order_date_", "location_","dough_","cheese_", "topping_","order_month_")], 
         function(x){return(sum(x))})

# Showing the cells of the cube
revenue_cube

#----------------------------------------------------------------------

# Build up a cube for profit
profit_cube <- 
  tapply(orders_fact$profit_, 
         orders_fact[,c("size_","order_date_", "location_")], 
         function(x){return(sum(x))})

# Showing the cells of the cube
profit_cube

#----------------------------------------------------------------------

# Build up a cube for profit
quantity_cube <- 
  tapply(orders_fact$quantity_, 
         orders_fact[,c("size_","order_date_", "location_")], 
         function(x){return(sum(x))})

# Showing the cells of the cube
quantity_cube

#----------------------------------------------------------------------

# Build up a cube for price
price_cube <- 
  tapply(orders_fact$price, 
         orders_fact[,c("size_","order_date_", "location_")], 
         function(x){return(sum(x))})

# Showing the cells of the cube
price_cube

#----------------------------------------------------------------------
  
  
#3. 
  
#Roll-up 1 - Revenue in terms of size and topping  
apply(revenue_cube, c("size_", "topping_"),
        FUN=function(x) {return(sum(x, na.rm=TRUE))})

#Roll-up 2 - Revenue in terms of size and dough 
apply(revenue_cube, c("size_", "dough_"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})

#Roll-up 3 - Revenue in terms of size and cheese
apply(revenue_cube, c("size_", "cheese_"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Roll-up 4 - Revenue in terms of dough and cheese
apply(revenue_cube, c("dough_", "cheese_"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})
  

#Roll-up 5 - Revenue in terms of dough and cheese
apply(revenue_cube, c("dough_", "topping_"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Roll-up 6 - Revenue in terms of size and location  
apply(revenue_cube, c("size_", "location_"),
      FUN=function(x) {return(sum(x, na.rm=TRUE))})

#--------------------------------------------------------------------


#Drill-down 1 - Revenue in terms of order_month_ and location_ and size_
apply(revenue_cube, c("order_month_", "location_", "size_"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Drill-down 2 - Revenue in terms of order_month_ and topping_ and size_
apply(revenue_cube, c("order_month_", "topping_", "size_"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Drill-down 3 - Revenue in terms of order_month_ and topping_ and size_
apply(revenue_cube, c("order_month_", "location_", "size_"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Drill-down 4 - Revenue in terms of order_month_ and topping_ and size_
apply(revenue_cube, c("dough_", "cheese_", "size_"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


#Drill-down 5 - Revenue in terms of order_month_ and topping_ and size_
apply(revenue_cube, c("size_", "dough_", "location_"), 
      FUN=function(x) {return(sum(x, na.rm=TRUE))})


