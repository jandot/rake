# Rake DSL functions.

# Declare a basic task.
#
# Example:
#   task :clobber => [:clean] do
#     rm_rf "html"
#   end
#
def task(*args, &block)
  Rake::Task.define_task(*args, &block)
end


# Declare a file task.
#
# Example:
#   file "config.cfg" => ["config.template"] do
#     open("config.cfg", "w") do |outfile|
#       open("config.template") do |infile|
#         while line = infile.gets
#           outfile.puts line
#         end
#       end
#     end
#  end
#
def file(*args, &block)
  Rake::FileTask.define_task(*args, &block)
end

# Declare a file creation task.
# (Mainly used for the directory command).
def file_create(args, &block)
  Rake::FileCreationTask.define_task(args, &block)
end

# Declare an event task.
#
# Example:
#   event :load_probes => [:load_individuals] do
#     File.open("my_file.txt").each do |line|
#       probe_name, individual_id = line.chomp.split(/\t/)
#       Probe.new(:name => probe_name, :individual_id => individual_id).new.save
#     end
#   end
def event(*args, &block)
  Rake::EventTask.define_task(*args, &block)
end

# Declare a set of files tasks to create the given directories on demand.
#
# Example:
#   directory "testdata/doc"
#
def directory(dir)
  Rake.each_dir_parent(dir) do |d|
    file_create d do |t|
      mkdir_p t.name if ! File.exist?(t.name)
    end
  end
end

# Declare a task that performs its prerequisites in parallel. Multitasks does
# *not* guarantee that its prerequisites will execute in any given order
# (which is obvious when you think about it)
#
# Example:
#   multitask :deploy => [:deploy_gem, :deploy_rdoc]
#
def multitask(args, &block)
  Rake::MultiTask.define_task(args, &block)
end

# Create a new rake namespace and use it for evaluating the given block.
# Returns a NameSpace object that can be used to lookup tasks defined in the
# namespace.
#
# E.g.
#
#   ns = namespace "nested" do
#     task :run
#   end
#   task_run = ns[:run] # find :run in the given namespace.
#
def namespace(name=nil, &block)
  name = name.to_s if name.kind_of?(Symbol)
  name = name.to_str if name.respond_to?(:to_str)
  unless name.kind_of?(String) || name.nil?
    raise ArgumentError, "Expected a String or Symbol for a namespace name"
  end
  Rake.application.in_namespace(name, &block)
end

# Declare a rule for auto-tasks.
#
# Example:
#  rule '.o' => '.c' do |t|
#    sh %{cc -o #{t.name} #{t.source}}
#  end
#
def rule(*args, &block)
  Rake::Task.create_rule(*args, &block)
end

# Describe the next rake task.
#
# Example:
#   desc "Run the Unit Tests"
#   task :test => [:build]
#     runtests
#   end
#
def desc(description)
  Rake.application.last_description = description
end

# Import the partial Rakefiles +fn+.  Imported files are loaded _after_ the
# current file is completely loaded.  This allows the import statement to
# appear anywhere in the importing file, and yet allowing the imported files
# to depend on objects defined in the importing file.
#
# A common use of the import statement is to include files containing
# dependency declarations.
#
# See also the --rakelibdir command line option.
#
# Example:
#   import ".depend", "my_rules"
#
def import(*fns)
  fns.each do |fn|
    Rake.application.add_import(fn)
  end
end
