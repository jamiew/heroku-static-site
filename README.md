heroku-static-site
===========

A simple ruby + rack application for serving a basic static website, suitable for deploying to [Heroku](http://heroku.com).
Their free 1-dyno plan covers 80% of my projects and Just Works&trade;

For even simpler free HTML cloud hosting check out [GitHub Pages](http://pages.github.com).

I put static sites on Heroku when I will be adding some simple dynamic stuff later,
or for redundancy with GH pages (whose uptime isn't perfect).


Usage
-----

Run the app locally:

1. `gem install bundler`
2. `bundle install`
3. `bundle exec rackup`
4. Visit <http://localhost:9292>

Make something great, then push it to your [Heroku](http://heroku.com) account:

1. `gem install heroku`
2. `heroku login`
2. `heroku create --stack=cedar mynewapp`
3. `git push heroku master`



License
-------

&copy; copyfree 2012 [Jamie Dubs](http://jamiedubs.com).
This source code made freely available under an [MIT License](http://www.opensource.org/licenses/mit-license.php).

