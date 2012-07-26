# encoding: utf-8

class Programm < ActiveRecord::Base
  attr_accessible :description, :vfs_path
  belongs_to :with_programm, :polymorphic => true
  validates_presence_of :description, :vfs_path, :with_programm
end
