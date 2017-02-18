require "console_runner/version"
require 'yard'
require 'console_runner_error'

class FileParser
  attr_reader :all_objects

  RUNNABLE_TAG = :runnable

  # Parse file with #YARD::CLI::Stats
  #
  # @param [String] file_path path to the file to be parsed,
  # @return[Array]
  def initialize(file_path)
    raise ConsoleRunnerError "Cannot find file #{file_path}" unless File.exist?(file_path)
    code = YARD::CLI::Stats.new
    code.run(file_path)
    @all_objects = code.all_objects
  end


  # @param [YARD::CodeObjects::ClassObject] clazz class object
  def list_methods(scope= :all, clazz = nil)
    all_methods = @all_objects.select { |o| o.type == :method }
    all_class_methods = []
    all_class_methods = clazz.children.select { |m| m.class == YARD::CodeObjects::MethodObject } if clazz

    case scope
      when :all
        if clazz
          all_class_methods
        else
          all_methods
        end
      when RUNNABLE_TAG
        if clazz
          all_class_methods.select { |m| m.has_tag? RUNNABLE_TAG }
        else
          all_methods.select { |m| m.has_tag? RUNNABLE_TAG }
        end
      else
        raise ':key can be :all or :runnable'
    end

  end

  def list_classes(scope= :all)
    all_classes = @all_objects.select { |o| o.type == :class }
    case scope
      when :all
        all_classes
      when RUNNABLE_TAG
        all_classes.select { |m| m.has_tag? RUNNABLE_TAG }
      else
        raise ':key can be :all or :runnable'
    end
  end

  def self.select_runnable_tags(yard_object)
    yard_object.tags.select{|t| t.tag_name == RUNNABLE_TAG.to_s }
  end

  def self.select_option_tags(yard_object)
    yard_object.tags.select{|t| t.tag_name == 'option' }
  end

  def self.select_param_tags(yard_object)
    yard_object.tags.select{|t| t.tag_name == 'param' }
  end

end

# YARD::Tags::Library.define_tag "Run in Console", :runnable, :with_types_and_name
YARD::Tags::Library.define_tag "Console Tool Description", FileParser::RUNNABLE_TAG