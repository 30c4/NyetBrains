# NyetBrains - Separate VSCode into different IDEs

Simply put, NyetBrains provides a way to separate your VSCode workflows into different instances.
This is possible because VSCode lets the user provide separate folders for both configuration files and extensions!
NyetBrains just helps you organise these folders by automatically putting them in a centralized folder.
On top of that you can make handy dandy shortcuts for every instance!

You can install NyetBrains by visiting the webpage at [https://nyetbrains.net](https://nyetbrains.net)

## Wait but how?
Like stated above, VSCode provides a way to use different folders for configuration files and extensions. If we combine this with a way to automatically create new folders and start VSCode with those folders we essentially create a separate instance!

Not only is it possible to create a blank instance, you can also create an instance with one of the available [variants](https://github.com/Jrprogrammer/NyetBrains/blob/master/variants/list.txt).

Choosing a variant sets up the instance with relevant extensions and configurations so you don't have to do it yourself! 

Even if you don't like the variant you chose, you can still modify the instance to your liking because it's just VSCode!

## This is awesome! How can I make my own variant?
If you just want to use the variant yourself you can start with the blank variant and build it yourself. 

If however, you want to publish your variant so that other people can use it too, please use the command `nyet -o [folder name]` to generate the list of extensions. You can then create a new issue with the 'New Variant' template.
