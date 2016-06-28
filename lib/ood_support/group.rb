require 'etc'

module OodSupport
  # A helper object describing a Unix group's details
  class Group
    include Comparable

    # The id of the group
    # @return [Fixnum] the group id
    attr_reader :id

    # The name of the group
    # @return [String] the group name
    attr_reader :name

    # @param group [Fixnum, #to_s] the group id or name
    def initialize(group = Process.group)
      if group.is_a?(Fixnum)
        @id = group
        @name = Etc.getgrgid(@id).name
      else
        @name = group.to_s
        @id = Etc.getgrnam(@name).gid
      end
    end

    # The comparison operator for sorting values
    # @param other [Group] group to compare against
    # @return [Fixnum] how groups compare
    def <=>(other)
      name <=> other
    end

    alias_method :eql?, :==

    # Generates a hash value for this object
    # @return [Fixnum] hash value of object
    def hash
      name.hash
    end

    # Convert object to string using group name as string value
    # @return [String] the group name
    def to_s
      name
    end
  end
end
