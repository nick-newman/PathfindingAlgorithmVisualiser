//grid list should contain bitmaps rather than coords
//highlight should check if grid list has a bitmap in the desired location and delete and place a new colored one

//create bitmap
//set pos using calculation
//add to grid list
//add to stage

//get bitmap from grid list x and y
//remove bitmap from stage
//create new bitmap
//add to grid list

//wall
//same as creating bitmap, determined to be a wall if not blank and not start/end

//clear nodes should reset algorithms/adjacencies and all non-removable bitmaps

//path needs to be highlighted after a do while loop running through a list of the bitmaps to be highlighted completes

//start/end use sprites containing bitmaps so when dragging is stopped, a method that is ran at mouse up has to set the new truncated position

//animation speed for placing highlighted visited nodes needs an html element

//calculate adjacencies should check if the adj candidate is not a wall by checking if it is empty or not

//extra
//drag to place multiple walls in one click
//moving start/end actively places it into position while dragging
//A*

//resizing should be limited to square, possibly add info such as amount of nodes and nodes in list/visited
//might cause problems with node size, sprite pos, etc. if the number does not divide evenly
//ex. 12*12 144 nodes inside a 1000/801 area, possibly solved using a cushion
//test by doing some sizes and printing square size, must not have a decimal, if it does it needs to use cushion
//or possibly truncate all decimals?