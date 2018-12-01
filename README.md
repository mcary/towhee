Towhee Web Framework
====================

Towhee is a web framework that is designed to address some of the
challenges of working with Rails:

* Some components in Rails are hard to test
* Rails is hard to extend because many component relationships are
  hard-coded
* Rails is memory-hungry

Other frameworks like Hamani partially address these concerns, but not to
the extent that I would like.

Testability
-----------

Three types of Rails components are particularly hard to test:

* Controllers must be tested via HTTP, now that controller specs are
  deprecated
* Views receive data by controller instance variables, and partials are
  hard to test in isolation
* Models are hard to test separately from the database, and, because of
  their broad public interface, they are hard to mock when passing them to
  other objects under test

Unfortunately, this covers the bulk of what Rails has to offer: all three
parts of the M-V-C architecture.

Towhee's counterparts were created via TDD, and they are designed with
testability in mind.

In addition, Towhee is designed for fast tests.  It is loaded _a la carte_
so that you can run individual tests without loading huge gems -- no
process loaders (such as Zeus or Spring) are required.

Prerendering
------------

Rails consumes large amounts of memory.  However most web apps are
read-heavy and many of their pages could be served as static files.  So
Towhee focuses on _prerendering_ views, for example to an S3 bucket or a
static filesystem served by Apache or Nginx.  Towhee provides a framework
for keeping these files up-to-date as models change, which means most
requests don't require any Ruby process at all.

While this befits mostly-public, mostly-content sites, it doesn't work for
everything.  So Tohee still supports dynamic pages for things like form
processing, admin UIs, and personalization.

PORO Views
----------

In Rails, views are hard to test in isolation because their input
requirements are not clearly identified.  In Towhee, input requirements are
clearly documented as method parameter lists.

In Rails, views are hard to test in isolation from their partials because
partials are hard to inject as dependencies.  In Towhee, a view is a
regular Ruby object whose livecycle you control, so you can inject
dependencies via the constructor or as method parameters.

In Rails, views have many helpers that are "magically" available because
Rails tends to mix in so many modules to views.  This can make it hard to
execute a view outside of the context of an HTTP request, for example.  But
in Towhee, these dependencies are explicit, not implicit, and they are
under your control.

Repository Model
----------------

In Rails, model classes and objects expose a huge number of ActiveRecord
methods that are difficult to stub or mock in tests and difficult to create
interfaces around.

Towhee supports a Repository model, where data fetching methods are
separate from the model objects, and you control the public APIs for both.

Multi-Table Inheritance
-----------------------

In Rails, creating schemas with foreign keys to arbitrary other types is
difficult:

* It's harder to create foreign key constraints in the database
* The application must manage both type and ID of the associated object

While it is still possible to use ActiveRecord with Towhee, Towhee's
Multi-Table Inheritance module allows you to identify an object with just
one ID.

Moreover, with Rails's Single-Table Inheritance, descendant models have
methods defined for attributes they may not use but are required for
sibling models.  This can result in sparse tables in the database and bugs
that are harder to notice.  Towhee's multi-table inheritance schema stores
fields that are specific to a subtype in a subtype-specific table, and it
lets you control your model's public API.

Fewer vs. Smaller Components
----------------------------

Rails architecture prefers fewer components over smaller components.  For
example, we have these layers:

* Model layer: ActiveRecord objects
* View layer: Templates and helpers
* Controller layer: Controllers

Having fewer components means more functionality in each component, making
it harder to separate concerns into composable components.

However, splitting these same layers into more components makes it easier
separate concerns, compose and reuse components, and keep their interfaces
small and testible.  For example:

* Model layer: Domain objects, persistence repository(ies), query objects,
  validators, access policies
* View layer: Smaller, templates with explicit context, composable as
  first-class compnents, presenters, and view models
* Controller layer: Request objects, response objects, and controllers
  focussed on a single action, and transaction objects that separate the
  business logic of an action from the web

While Rails or its plugin ecosystem offer some of these components, they
tend to be tightly coupled.  For example, if you want to use the Rails
validator API on an object, it has to supply an Errors object that responds
to a fairly rich API.

And the broad API exposed by many Rails components makes it very hard to
substitute an alternative implementation.

Towhee leans towards more smaller components.  While this makes individual
components easier to work with, it does have a potential drawback of having
more components to manage -- more assembly of the components.  If you like
TDD with unit tests, or if your app grows beyond the 15-minute blog app
that made Rails famous, you'll start to see the benefits of this tradeoff.

Status
------

Towhee is in early stages of development.  It's an experiment.  Many
feature areas are incomplete.  However, there is enough working code to
look at it for inspiration in your own applications.  And of course, you
can always specify a tight version constraint in your gemfile to protect
yourself from future breaking changes.

Developing
----------

    bundle install
    rspec

Front-end: Javascript and CSS
-----------------------------

See the `frontend` subdirectory and the Towhee::Blog example app for ideas
about how to integrate this with NPM and the NodeJS ecosystem.
