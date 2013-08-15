class Graph
	
	# @param [Array<Array>] edges A list of "paths" formed by the vertices that make up the whole graph
	def initialize paths = []
		@adjacency_list = {}
		paths.each do |path|
			path.each_cons(2) do |x,y|
				@adjacency_list[x] ||= Array.new
				@adjacency_list[y] ||= Array.new
				@adjacency_list[x].push y unless @adjacency_list[x].include? y
				@adjacency_list[y].push x unless @adjacency_list[y].include? x
			end
		end
	end
	
	def self.import path
		paths = Array.new
		File.open(path, "r").each_line do |line|
			next if line.include? "}" or line.include? "{"
			line.strip
			line.chomp ";"
			paths.push line.split(" -- ")
		end
		self.new paths
	end
	
	def self.random
		n = rand(10)
		p = ((1..n).inject(:*) || 1)/(2*((1..(n-2)).inject(:*) || 1))
		e = rand(p)
		edges = Array.new
		count = 0
		while count < e do
			x = (rand(n)+65).chr
			y = (rand(n)+65).chr
			unless x == y or edges.include? [x,y] or edges.include? [y,x]
				edges.push [x,y]
				count += 1
			end
		end 
		self.new edges
	end
	
	def adjacent x, y 
		@adjacency_list[x].include? y
	end
	
	def neighbors vertex
		@adjacency_list[vertex]
	end
	
	def add_edge x, y
		@adjacency_list[x].push y
		@adjacency_list[y].push x
	end
	
	def add_vertex x, ys = []
		@adjacency_list[x] ||= ys
	end
	
	def delete_edge x, y
		@adjacency_list[x].delete y
		@adjacency_list[y].delete x
	end
	
	def delete_vertex x
		neighbors(x).each { |y| @adjacency_list[y].delete x }
		@adjacency_list.delete x
	end
	
	def path so_far, edges_considered
		x = so_far.last
	
		possible = neighbors(x).clone
		possible.delete_if { |p| so_far.include? p or edges_considered.include? [x,p] or edges_considered.include? [p,x] }
		return { :so_far => so_far, :edges_considered => edges_considered } if possible.empty?
		y = possible.sample
		so_far.push y
		edges_considered.push [x,y]
		return path so_far, edges_considered
	end
			
	# gets strings that will encode the vertices in as few lines of DOT as possible
	def dot_encoding_strings
		enc = Array.new
		edges_considered = Array.new
		@adjacency_list.keys.each do |v|
			result = path [v], edges_considered
			enc.push result[:so_far].join(" -- ") unless result[:so_far].length == 1 and !neighbors(result[:so_far].first).empty?
			edges_considered = result[:edges_considered]
		end
		enc 
	end
	
	def export_to_dot options = {}
		path = options[:path] || ""
		path << "/" unless path.end_with? "/" or path.eql? ""
		filename = options[:filename] || "my_graph"
		timestamp = Time.now.strftime "%Y-%m-%dT%H-%M-%S"
		File.open("#{path}#{filename}.dot", "w") do |f|
			f.write("graph #{filename} {\n")
			dot_encoding_strings.each do |s|
				f.write "\t#{s};\n"
			end
			f.write "}"
		end
	end 
	
	def export options = {}
		path = options[:path] || ""
		path << "/" unless path.end_with? "/" or path.eql? ""
		filename = options[:filename] || "my_graph"
		type = options[:type] || "png"
		export_to_dot options
		system("dot -T#{type} #{filename}.dot -o #{filename}.#{type}")
	end
	
	def shortest_path
	
end

g = Graph.random
g.export :filename => "random_graph"