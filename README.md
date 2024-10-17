# README

## Steps
1. Setup Boilerplate rails application using `rails new birds-api --api -d postgresql`
2. Delete extra goodies we don't need (ActionCable, Etc)
3. Unzip nodes.csv.gz using `gzip -d data/nodes.csv.gz`
4. Create the database `bundle exec rake db:create`
5. Create the model using `rails g model nodes`
6. Create the table using `bundle exec rake db:migrate`
   * Note, I decided not to use foreign key constraints as in the future we may need to add children before their parents.
7. Seed the initial data using `rails db:seed`
8. Choose `acts_as_tree` gem to handle self references
9. Add `parents`, `root`, and `lowest_common_ancestor` methods to the model
10. Add `rspec` & `rubocop`
11. Create the api contoller using `rails g controller CommonAncestors`
12. Update the `config/routes.rb`
13. Add the birds model using `rails g model Bird`

## Model Selection
Decide between the following ways to model the self referencing relationship
   1. First attempt `acts_as_tree` gem.

## Getting Started

