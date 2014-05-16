module Pod
  class Command
    class Roulette < Command
      self.summary = "Creates a new iOS project with three random pods"

      self.description = <<-DESC
        Creates a new iOS project with three random pods.
      DESC
      
      def self.options
        [[
          "--update", "Run `pod repo update` before rouletting",
        ]].concat(super)
      end

      def initialize(argv)
        @update = argv.flag?('update')
        super
      end

      def liftoff_installed?
        `which liftoff`
        $?.exitstatus.zero?
      end

      def validate!
        super

        unless liftoff_installed?
          help! [
            'PodRoulette requires Liftoff (which has to be installed through Homebrew). Please install it first.',
            '',
            '$ brew tap thoughtbot/formulae',
            '$ brew install liftoff'
          ].join("\n")
        end
      end

      def humanize_pod_name(name)
        name = name.gsub /(^|\W)(\w)/ do |match|
          Regexp.last_match[2].upcase
        end
        name = name.gsub /[^a-z]/i, ''
        name.gsub /^[A-Z]*([A-Z][^A-Z].*)$/, '\1'
      end

      def run
        update_if_necessary!

        all_specs = Pod::SourcesManager.all_sets
        # TODO: reactivate only those pods that support iOS
        # all_specs.reject!{ |set| !set.specification.available_platforms.map(&:name).include?(:ios) }

        picked_specs = all_specs.sample 3

        project_name = picked_specs.map do |random_spec|
          humanize_pod_name random_spec.name
        end.join ''

        print project_name + "\n"

      end
      
      def update_if_necessary!
        Repo.new(ARGV.new(["update"])).run if @update
      end
    end
  end
end
