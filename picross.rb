require 'pp'

@cols = [[7, 2, 1, 1, 7],
 [1, 1, 2, 2, 1, 1],
 [1, 3, 1, 3, 1, 3, 1, 3, 1],
 [1, 3, 1, 1, 5, 1, 3, 1],
 [1, 3, 1, 1, 4, 1, 3, 1],
 [1, 1, 1, 2, 1, 1],
 [7, 1, 1, 1, 1, 1, 7],
 [1, 1, 3],
 [2, 1, 2, 1, 8, 2, 1],
 [2, 2, 1, 2, 1, 1, 1, 2],
 [1, 7, 3, 2, 1],
 [1, 2, 3, 1, 1, 1, 1, 1],
 [4, 1, 1, 2, 6],
 [3, 3, 1, 1, 1, 3, 1],
 [1, 2, 5, 2, 2],
 [2, 2, 1, 1, 1, 1, 1, 2, 1],
 [1, 3, 3, 2, 1, 8, 1],
 [6, 2, 1],
 [7, 1, 4, 1, 1, 3],
 [1, 1, 1, 1, 4],
 [1, 3, 1, 3, 7, 1],
 [1, 3, 1, 1, 1, 2, 1, 1, 4],
 [1, 3, 1, 4, 3, 3],
 [1, 1, 2, 2, 2, 6, 1],
 [7, 1, 3, 2, 1, 1]]

@rows = [[7, 3, 1, 1, 7],
 [1, 1, 2, 2, 1, 1],
 [1, 3, 1, 3, 1, 1, 3, 1],
 [1, 3, 1, 1, 6, 1, 3, 1],
 [1, 3, 1, 5, 2, 1, 3, 1],
 [1, 1, 2, 1, 1],
 [7, 1, 1, 1, 1, 1, 7],
 [3, 3, 1, 1, 1, 3, 1],
 [1, 2, 3, 1, 1, 3, 1, 1, 2],
 [1, 1, 3, 2, 1, 1],
 [4, 1, 4, 2, 1, 2],
 [1, 1, 1, 1, 1, 4, 1, 3],
 [2, 1, 1, 1, 2, 5],
 [3, 2, 2, 6, 3, 1],
 [1, 9, 1, 1, 2, 1],
 [2, 1, 2, 2, 3, 1],
 [3, 1, 1, 1, 1, 5, 1],
 [1, 2, 2, 5],
 [7, 1, 2, 1, 1, 1, 3],
 [1, 1, 2, 1, 2, 2, 1],
 [1, 3, 1, 4, 5, 1],
 [1, 3, 1, 3, 10, 2],
 [1, 3, 1, 1, 6, 6],
 [1, 1, 2, 1, 1, 2],
 [7, 2, 1, 2, 5]]
 
@grid = Array.new(@cols.size){Array.new(@rows.size, '?')}

row_shifts = @rows.map{|r| @cols.size - (r.size - 1 + r.reduce(&:+))}
col_shifts = @cols.map{|r| @rows.size - (r.size - 1 + r.reduce(&:+))}

@gap_cache = {}
def generate_gaps(remaining_size, solids, starting_value, known_mask)
  solid_key = solids * ','
  mask_key = known_mask * ''
  
  unless @gap_cache.has_key? starting_value
    @gap_cache[starting_value] = {}
  end
  
  unless @gap_cache[starting_value].has_key? remaining_size
    @gap_cache[starting_value][remaining_size] = {}
  end
  
  unless @gap_cache[starting_value][remaining_size].has_key? solid_key
    @gap_cache[starting_value][remaining_size][solid_key] = {}
  end
  
  safe_solids = Array.new(solids)
  unless @gap_cache[starting_value][remaining_size][solid_key].has_key? mask_key
    next_solid = (safe_solids.shift or 0)
    max_size = remaining_size - (safe_solids.size)
    max_size = (known_mask.first(max_size).index('X') or max_size)
    min_solid_match = known_mask[starting_value, next_solid]
    
    if max_size < starting_value or min_solid_match.size < next_solid or (next_solid == 0 and not min_solid_match.index('.').nil?)
	  puts "1: Remaining: #{remaining_size}, Solids: #{solid_key}, Mask: #{mask_key}"
	  puts "1: Max Size: #{max_size}, Starting Value: #{starting_value}, Next Solid: #{next_solid}, Min Solid Match: #{min_solid_match}"
      @gap_cache[starting_value][remaining_size][solid_key][mask_key] = nil
    elsif next_solid == 0
      @gap_cache[starting_value][remaining_size][solid_key][mask_key] = [[remaining_size]]
    else
      stop = false
      results = starting_value.upto(remaining_size - (safe_solids.size)).map { |gap|
        next if stop or not known_mask[gap, next_solid].index('.').nil?
        new_mask = known_mask[gap + next_solid..-1]
        gaps = generate_gaps(remaining_size - gap, safe_solids, (safe_solids.size == 0 ? 0 : 1), new_mask)
        stop ||= gaps.nil?
        next if stop
        gaps.compact.map{|x| Array.new(x).unshift(gap).flatten(1)}
      }.compact.flatten(1)
	  puts "2: Remaining: #{remaining_size}, Solids: #{solid_key}, Mask: #{mask_key}" if results.empty?
      @gap_cache[starting_value][remaining_size][solid_key][mask_key] = results.empty? ? nil : results
    end
  end
  puts "3: Remaining: #{remaining_size}, Solids: #{solid_key}, Mask: #{mask_key}" if @gap_cache[starting_value][remaining_size][solid_key][mask_key].nil?
  @gap_cache[starting_value][remaining_size][solid_key][mask_key]
end

def find_overlap gaps, solids
  gaps.map {|gap_set| 
    (gap_set.map{|x| '.' * x}.zip(solids.map{|x| 'X' * x}).flatten.compact * '').scan(/./)
  }.transpose.map{|x|
    x.uniq.size == 1 ? x.uniq.first : '?'
  }
end

def display_grid grid
  puts grid.map{|row| row * ''} * "\n"
end

def merge_grids g1, g2
  g1.zip(g2).map{|r| r.transpose}.map{|r|
    r.map{|c| (c - ['?']).uniq.first or '?'}
  }
end

def iterate
  transposed_grid = @grid.transpose
  @grid = merge_grids(@grid, @rows.each_with_index.map {|r, index|
    remaining_size = @cols.size - r.reduce(&:+)
    gaps = generate_gaps(remaining_size, r, 0, transposed_grid[index])
	puts "Row: #{index}, Gap Count: #{gaps.size}"
    find_overlap(gaps, r)
  }.transpose)
  
  display_grid @grid
  
  @grid = merge_grids(@grid, @cols.each_with_index.map{|c, index| 
    remaining_size = @rows.size - c.reduce(&:+)
    gaps = generate_gaps(remaining_size, c, 0, transposed_grid[index])
	puts "Col: #{index}, Gap Count: #{gaps.size}"
    find_overlap(gaps, c)
  })
  
  display_grid @grid
end

iterate
iterate
