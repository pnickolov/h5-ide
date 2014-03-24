
This folder contains and only contains testcase used for automated test before deploying.
And should not place any other things.

The test framework we use is `Mocha` and `should.js` :
Mocha - http://visionmedia.github.io/mocha/
should.js - https://github.com/visionmedia/should.js

Due to the fact that it is difficult to write testcase for the IDE. It is strongly discouraged to write testcase if :
  1. You don't have solid understanding of the test process.
  2. You don't have solid understanding of Mocha and should.js
  3. You don't have solid understanding of Zombie

A very pratical example of an testcase is under test/default.coffee. Please use this testcase as an reference if you want to write testcase.
