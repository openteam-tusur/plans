# encoding: utf-8

require 'spec_helper'

describe Person do
  subject { Person.new(:name => "Петров Иван Сергеевич") }
  its(:short_name) { should == 'Петров И.С.' }
end
