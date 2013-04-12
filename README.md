## Vcdelta.org README

This is the code that powers VCDelta.org. It's a Rails 4 application hosted on Heroku.

### Purpose

VCDelta.org makes it easy to create an 'Investments.js' file - a format proposed by Jerry Neumann for sharing machine-readable investment information. For more information, see this [blog post](http://reactionwheel.blogspot.com/2013/04/a-mechanism-for-vc-deal-transparency.html).

At VCDelta.org, investors can construct their Investments.js file by entering information in a web form. They can optionally import information from Crunchbase. Once they have an Investments.js file, they can edit and then recreate it by importing it.

VCDelta.org doesn't host Investments.js files, and there's no persistence between sessions - investors are responsible for saving their Investments.js files and hosting it themselves.

### Investments.js

Information on the Investments.js specification can be found [here](http://vcdelta.org/specification).

### To-do

Things I may do someday:

* Create a central page that links to Investments.js files around the web.
* Add user accounts to VCDelta so investors can store Investments.js files and save them between sessions.
* Give users the ability to add their own Investments.js files to the central listing page.

### Notes

Suggestions for improving code quality are always welcome.