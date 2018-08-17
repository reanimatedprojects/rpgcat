# How to contribute

We're really glad you're reading this, because we need volunteers to help with this project.

Here are some important resources:

  * Our company website - [Reanimated Projects and Games](http://www.reanimated.co.uk/)
  * Discord server - come find us on [Discord](https://discordapp.com/). Our server invite code is MeSscUG - there should be a button to create/join a new server. Simply click the button, choose Join and enter this code to add our server to your account.
  * Enter them as [GitHub Issues](https://github.com/rpgwnn/rpgcat/issues). Not sure if it's a bug? Talk to us on Discord first or create a detailed issue and we'll let you know if it's not a bug.

## Testing

We have no testing procedure as there's very little functionality yet - if you know how to write good Perl module tests we would love for you to contribute some information!

## Wanted

* Perl developers - specifically Catalyst apps and tests
* People who like to get creative with textual descriptions or simple graphics
* Anyone who knows about User Experience or User Interface Design
* Testers able to file useful bug reports

Don't quite fit any of those categories but still want to get involved? Drop by Discord and talk to us!

## Submitting changes

Please send a [GitHub Pull Request to rpgcat](https://github.com/rpgwnn/rpgcat/pull/new/master) with a clear list of what you've done (read more about [pull requests](http://help.github.com/pull-requests/)). Please follow our coding conventions (below) and make sure all of your commits are atomic (one feature per commit).

Always write a clear log message for your commits. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

## Coding conventions

Start reading our code and you'll hopefully see how we do things. Readable code is preferred so if we messed up somewhere, submit a Pull Request with a fix! :)

  * We indent using four spaces (soft tabs)
  * We use HTML and Template Toolkit for all views
  * We try to remember to put spaces after list items and method parameters (`[1, 2, 3]`, not `[1,2,3]`), around operators (`x += 1`, not `x+=1`), and around hash arrows (`x => 1`).
  * This is open source software. Consider the people who will have to understand what you've written and don't make it difficult for them.
  * Don't hardcode absolute paths to files - try to use various methods for generating the right path if you need an absolute path, or use a relative path if possible.

Thanks!
