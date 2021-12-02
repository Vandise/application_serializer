require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  self.verbose = false
  create_table :people, force: true do |t|
    t.string :name
    t.string :catch_phrase
    t.timestamps null: false
  end
end

class Person < ActiveRecord::Base; end;

class PersonSerializer < ApplicationSerializer::Base
  context :show do
    [:id, :name, :catch_phrase]
  end

  context :list do |scope, serializer|
    serializer.attribute :id, key: :key
    serializer.attribute :name, key: :value
  end

  context :byline do
    [:byline]
  end

  def byline
    "#{object.name} says '#{object.catch_phrase}'"
  end
end