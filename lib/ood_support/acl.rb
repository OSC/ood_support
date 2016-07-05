module OodSupport
  # A helper object that describes an access control list (ACL) with entries
  class ACL
    # The entries of this ACL
    # @return [Array<ACLEntry>] list of entries
    attr_reader :entries

    # Whether this ACL defaults to allow, otherwise default deny
    # @return [Boolean] whether default allow
    attr_reader :default

    # @param entries [#to_s] list of entries
    # @param default [Boolean] default allow, otherwise deny
    def initialize(entries:, default: false)
      @default = default

      # Build up list of entries from string
      @entries = entries.is_a?(Array) ? entries : parse_entries(entries)

      # Add a `to_s` method to entries list
      add_entries_string_method
    end

    # Check if queried principle has access to resource
    # @param principle [String] principle to check against
    # @return [Boolean] does principle have access?
    def allow?(principle:)
      # Check in array order
      ordered_check(principle: principle)
    end

    # Convert object to hash
    # @return [Hash] the hash describing this object
    def to_h
      { entries: entries.to_s, default: default }
    end

    # The comparison operator
    # @param other [#to_h] entry to compare against
    # @return [Boolean] how acls compare
    def ==(other)
      to_h == other.to_h
    end

    # Checks whether two ACL objects are completely identical to each other
    # @param other [ACL] entry to compare against
    # @return [Boolean] whether same objects
    def eql?(other)
      self.class == other.class && self == other
    end

    # Generates a hash value for this object
    # @return [Fixnum] hash value of object
    def hash
      [self.class, to_h].hash
    end

    private
      # Parse a string of entries
      def parse_entries(entries)
        e = []
        entries.to_s.strip.split(/\n|,/).grep(/^[^#]/).each do |entry|
          e << entry_class.parse(entry)
        end
        e
      end

      # Class used to generate an entry
      def entry_class
        ACLEntry
      end

      # Add a `to_s` method to the entries list
      def add_entries_string_method
        # Convert list of entries to string
        def @entries.to_s
          join("\n")
        end
      end

      # Check each entry in order from array
      def ordered_check(**kwargs)
        entries.each do |entry|
          if entry.match(**kwargs)
            # Check if its an allow or deny acl entry (may not be both)
            return true  if entry.is_allow?
            return false if entry.is_deny?
          end
        end
        return default # default allow or default deny
      end
  end
end
