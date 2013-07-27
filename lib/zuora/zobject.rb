# ZObject
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

require 'builder'

module Zuora

  # (derived from
  # http://pullmonkey.com/2008/01/06/convert-a-ruby-hash-into-a-class-object/)
  class ZObject

    def initialize(*args)
      case args.size()
      when 0
      when 1
        init_hash *args
      else
        error
      end
    end

    def init_hash(hash)

      hash.each do |k,v|

        var_name = k.to_s.parameterize("__")

        # create and initialize an instance variable for this key/value pair
        self.instance_variable_set("@#{var_name}", v)

        # create the getter that returns the instance variable
        self.class.send(:define_method, k,
            proc{self.instance_variable_get("@#{var_name}")})

        # create the setter that sets the instance variable
        self.class.send(:define_method, "#{var_name}=",
            proc{|v| self.instance_variable_set("@#{var_name}", v)})

      end

    end

    def method_missing(key, *args)

      text = key.to_s
      if text[-1, 1] == "=" then
        var_name = text.chomp("=")

        # create and initialize an instance variable for this key/value pair
        self.instance_variable_set("@#{var_name}", args[0])

        # create the getter that returns the instance variable
        self.class.send(:define_method, var_name,
            proc{self.instance_variable_get("@#{var_name}")})

        # create the setter that sets the instance variable
        self.class.send(:define_method, "#{var_name}=",
            proc{|v| self.instance_variable_set("@#{var_name}", v)})

        self.instance_variable_get("@#{var_name}")

      else

        self.instance_variable_get("@#{text}")

      end

    end

    def to_hash
      hash_to_return = {}
      self.instance_variables.each do |var|
        hash_to_return[var.to_s.gsub("@", "")] = self.instance_variable_get(var)
      end
      return hash_to_return
    end

    def to_xml(element_name, attribute_hash = {})
      
      # Merge namespace declarations with attribute_hash passed into
      # method
      attribute_hash = { :"xmlns:obj" => "http://object.api.zuora.com/",
          :"xmlns:api" => "http://api.zuora.com/",
          :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance" } \
          .merge attribute_hash
          
      # Using the instance variables in this object, build a hash of
      # fully-qualified elements
      element_hash = to_hash
      new_element_hash = {}
      element_hash.each do |k, v|
        if k.to_s.start_with?("@") then
          attribute_name = k.to_s.gsub("@", "")
          if !v.nil? then
            attribute_hash[attribute_name.to_sym] = v
          end
        else
          if !v.nil? then
            new_element_hash[k.to_s.to_sym] = v
          end
        end
      end
      
      # Construct and return XML from the generated hashes
      xml = Builder::XmlMarkup.new
      xml.tag!(element_name, attribute_hash) do
        new_element_hash.each do |k, v|
          if v.is_a? Array
            v.each do |item|
              if item.class.method_defined? :to_xml
                xml << item.to_xml("api:#{k.to_s}")
              else
                xml.tag!("obj:#{k.to_s}", item)
              end
            end
          else
            if v.class.method_defined? :to_xml
              xml << v.to_xml("api:#{k.to_s}")
            else
              xml.tag!("obj:#{k.to_s}", v)
            end
          end
        end
        xml.target!
      end
      xml.target!
      
    end

  end
  
end