module OodSupport
  module ACLs
    # Object describing an NFSv4 ACL
    class Nfs4ACL < ACL
      # Name of owner for this ACL
      # @return [String] owner name
      attr_reader :owner

      # Name of owning group for this ACL
      # @return [String] group name
      attr_reader :group

      # Get ACL from file path
      # @param file [String] path to file
      def self.get_facl(file:)
        path = Pathname.new file
        stat = path.stat
        owner = User.new(stat.uid)
        group = Group.new(stat.gid)
        entries = `nfs4_getfacl #{file}`
        new(entries: entries, owner: owner, group: group)
      end

      # @param owner [#to_s] name of owner
      # @param group [#to_s] name of group
      # @see ACL#initialize
      def initialize(owner:, group:, **kwargs)
        @owner = owner.to_s
        @group = group.to_s
        super(kwargs.merge(default: false))
      end

      # Check if queried principle has access to resource
      # @param principle [User, Group] principle to check against
      # @param permission [Symbol] permission to check against
      # @return [Boolean] does principle have access?
      def allow?(principle:, permission:)
        # Check in array order
        ordered_check(principle: principle, permission: permission, owner: owner, group: group)
      end

      private
        # Use Nfs4Entry for entry objects
        def entry_class
          Nfs4Entry
        end
    end

    # Object describing single NFSv4 ACL entry
    class Nfs4Entry < ACLEntry
      # Valid types for an ACL entry
      VALID_TYPE = %i[ A U D L ]

      # Valid flags for an ACL entry
      VALID_FLAG = %i[ f d p i S F g ]

      # Valid permissions for an ACL entry
      VALID_PERMISSION = %i[ r w a x d D t T n N c C o y ]

      # Regular expression used when parsing ACL entry string
      REGEX_PATTERN = %r[^(?<type>[#{VALID_TYPE.join}]):(?<flags>[#{VALID_FLAG.join}]*):(?<principle>\w+)@(?<domain>[\w\.\-]*):(?<permissions>[#{VALID_PERMISSION.join}]+)$]

      # Type of ACL entry
      # @return [Symbol] type of acl entry
      attr_reader :type

      # Flags set on ACL entry
      # @return [Array<Symbol>] flags on acl entry
      attr_reader :flags

      # Domain of ACL entry
      # @return [String] domain of acl entry
      attr_reader :domain

      # Permissions of ACL entry
      # @return [Array<Symbol>] permissions of acl entry
      attr_reader :permissions

      # @param type [#to_sym] type of acl entry
      # @param flags [Array<#to_sym>] list of flags for entry
      # @param domain [#to_s] domain of principle
      # @param permissions [Array<#to_sym>] list of permissions for entry
      # @see ACLEntry#initialize
      def initialize(type:, flags:, domain:, permissions:, **kwargs)
        @type = type.to_sym
        @flags = flags.map(&:to_sym)
        @domain = domain.to_s
        @permissions = permissions.map(&:to_sym)
        super(kwargs)
      end

      # Is this an "allow" ACL entry
      # @return [Boolean] is this an allow entry
      def is_allow?
        type == :A
      end

      # Is this a "deny" ACL entry
      # @return [Boolean] is this a deny entry
      def is_deny?
        type == :D
      end

      # Do the requested args match this ACL entry?
      # @param principle [User, Group] requested principle
      # @param permission [#to_sym] requested permission
      # @param owner [String] owner of corresponding ACL
      # @param group [String] owning group of corresponding ACL
      # @return [Boolean] does this match this entry
      def match(principle:, permission:, owner:, group:)
        raise StandardError if !principle.is_a?(User) && !principle.is_a?(Group)
        this_principle = self.principle
        this_principle = owner     if self.principle == "OWNER"
        this_principle = group     if self.principle == "GROUP"
        this_principle = principle if self.principle == "EVERYONE"
        if principle.is_a?(User) && group_entry?
          principle.groups.include?(this_principle) && permissions.include?(permission.to_sym)
        elsif principle.is_a?(User) || (principle.is_a?(Group) && group_entry?)
          principle == this_principle && permissions.include?(permission.to_sym)
        else
          false
        end
      end

      # Is this a group-specific ACL entry
      # @return [Boolean] is this a group entry
      def group_entry?
        flags.include? :g
      end

      # Convert object to string
      # @return [String] the string describing this object
      def to_s
        "#{type}:#{flags.join}:#{principle}@#{domain}:#{permissions.join}"
      end

      private
        # Parse an entry string into input parameters
        def self.parse_entry(entry)
          entry = REGEX_PATTERN.match(entry.to_s.strip) do |m|
            {
              type:        m[:type],
              flags:       m[:flags].chars,
              principle:   m[:principle],
              domain:      m[:domain],
              permissions: m[:permissions].chars
            }
          end
          entry ? entry : raise(StandardError)
        end
    end
  end
end
