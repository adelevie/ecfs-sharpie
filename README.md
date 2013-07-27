# ecfs-sharpie

This is an example application that uses the [sharpie](https://github.com/adelevie/sharpie) gem to create static HTML and JSON pages for FCC filings.

## Usage

```sh
$ bundle
$ ruby render.rb
```

Upload the contents of `_site` to any server you want.

You can also use node.js to run the small dev server:

```sh
$ npm install connect
$ node dev-server.js
```

Then go to `localhost:1337/_site/proceedings/12-375`.