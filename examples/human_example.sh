source $PWD/examples/human.sh

# create an object called 'mark' of type Human
oo mark = new Human
oo mark . name = 'Mark G. Smith'
oo mark . height = 180
oo mark : eat 'corn'
oo mark : eat 'blueberries'

# get properties
echo $(oo result = mark . name)
oo description = mark : describeYourSelf
echo $description
