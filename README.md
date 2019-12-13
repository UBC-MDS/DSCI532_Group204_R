# DSCI532_Group204_R

## Dash App: Milestone 4

*The R app will be accessible by December 14, 2019**

### Summary of App Functionality

This app allows users to visualize details of over 50,000 wine reviews from across the United States, using data scraped from Wine Enthusiast on November 22nd, 2017. Given the data source, the wines tend to be of relatively high quality, with each receiving a rating score between 80 and 100. We’ve used these ratings to assign a ‘value’ score to each wine, which is essentially a ratio of its rating to price. Each review also contains details such as grape variety, winery, region, county, and state.

The ‘Geographic Analysis’ tab shows how wine is distributed across the U.S. A user can hover over a particular state or county to see things like average price, points (rating), or value. A dropdown menu allows users to take a closer look at a particular state, where they can see a breakdown by county. Hovering over a county provides similar summary information.

The ‘Explore Rating, Price & Value of Wines’ tab allows users to explore the price, points (rating) and value for different wineries, grape varieties, and regions. The bar chart shows dynamically ranked results for calculated averages. Dropdowns allow the user to select which data to display on each axis, a slider is provided to select how many bars to display, and there is a radio button selection to choose to rank the bars in either ascending or descending order. The heat map shows the distribution of value (scaled rating / price) for popular grape varieties across either price or rating ranges, depending on the dropdown selection.


#### Geographic View

![Sketch](imgs/updated_sketch_p1.png)

#### Wine Feature View

![Sketch](imgs/updated_sketch_p2.png)