require 'pp'

ACTIVE_SYMBOL = 'X'
INACTIVE_SYMBOL = ' '
UNKNOWN_SYMBOL = '.'

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
         [7, 1, 3, 2, 1, 1]
]

@rows = [[7, 3, 1, 1, 7],
         [1, 1, 2, 2, 1, 1],
         [1, 3, 1, 3, 1, 1, 3, 1],
         [1, 3, 1, 1, 6, 1, 3, 1],
         [1, 3, 1, 5, 2, 1, 3, 1],
         [1, 1, 2, 1, 1],
         [7, 1, 1, 1, 1, 1, 7],
         [3, 3],
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
         [7, 2, 1, 2, 5]
]

@known_active = [
    [8, 6],
    [8, 7],
    [8, 10],
    [8, 18],
    [16, 6],
    [16, 11],
    [16, 16],
    [16, 20],
    [21, 9],
    [21, 10],
    [21, 15],
    [21, 20],
    [21, 21]
]

@grid = Array.new(@cols.size){Array.new(@rows.size, UNKNOWN_SYMBOL)}

@known_active.each{|coordinate|
  @grid[coordinate.first][coordinate.last] = ACTIVE_SYMBOL
}

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
    matched_index = known_mask.first(max_size).index(ACTIVE_SYMBOL)
    max_size = matched_index.nil? ? max_size : (matched_index + 1)
    new_start = starting_value
    # until known_mask[new_start, next_solid].nil? or known_mask[new_start, next_solid].index(INACTIVE_SYMBOL).nil? or new_start >= max_size
    #   new_start = new_start + ((known_mask[new_start, next_solid].index(INACTIVE_SYMBOL) or 0) + 1)
    #   puts "New Start: #{new_start}, Mask: #{known_mask}, Next Solid: #{next_solid}, Match: #{known_mask[new_start, next_solid].index(INACTIVE_SYMBOL)}"
    # end
    min_solid_match = known_mask[new_start, next_solid]

    if max_size < new_start or min_solid_match.size < next_solid or (next_solid == 0 and not min_solid_match.index(INACTIVE_SYMBOL).nil?)
      puts "1: Remaining: #{remaining_size}, Solids: #{solid_key}, Mask: #{mask_key}"
      puts "1: Max Size: #{max_size}, New Start: #{new_start}, Starting Value: #{starting_value}, Next Solid: #{next_solid}, Min Solid Match: #{min_solid_match}"
      @gap_cache[starting_value][remaining_size][solid_key][mask_key] = nil
    elsif next_solid == 0
      @gap_cache[starting_value][remaining_size][solid_key][mask_key] = [[remaining_size]]
    else
      stop = false
      results = new_start.upto(remaining_size - (safe_solids.size)).map { |gap|
        next if stop or not known_mask.first(gap).index(ACTIVE_SYMBOL).nil? or not known_mask[gap, next_solid].index(INACTIVE_SYMBOL).nil?
        new_mask = known_mask[gap + next_solid..-1]
        gaps = generate_gaps(remaining_size - gap, safe_solids, (safe_solids.size == 0 ? 0 : 1), new_mask)
        next if gaps.nil?

        gaps.compact.map{|x| Array.new(x).unshift(gap).flatten(1)}
      }.compact.flatten(1)
      puts "2: Remaining: #{remaining_size}, Solids: #{solid_key}, Mask: #{mask_key}" if results.empty?
      @gap_cache[starting_value][remaining_size][solid_key][mask_key] = results.empty? ? nil : results
    end
  end
  #puts "3: Remaining: #{remaining_size}, Solids: #{solid_key}, Mask: #{mask_key}" if @gap_cache[starting_value][remaining_size][solid_key][mask_key].nil?
  @gap_cache[starting_value][remaining_size][solid_key][mask_key]
end

def find_overlap gaps, solids
  gaps.map {|gap_set|
    (gap_set.map{|x| INACTIVE_SYMBOL * x}.zip(solids.map{|x| ACTIVE_SYMBOL * x}).flatten.compact * '').scan(/./)
  }.transpose.map{|x|
    x.uniq.size == 1 ? x.uniq.first : UNKNOWN_SYMBOL
  }
end

def display_grid grid
  puts '╔' + ('═' * grid.size) + '╗'
  puts grid.map{|row| '║' + row * '' + '║'} * "\n"
  puts '╚' + ('═' * grid.size) + '╝'
end

def merge_grids g1, g2
  g1.zip(g2).map{|r| r.transpose}.map{|r|
    r.map{|c| (c - [UNKNOWN_SYMBOL]).uniq.first or UNKNOWN_SYMBOL}
  }
end

display_grid @grid

def iterate
  @grid = merge_grids(@grid, @rows.each_with_index.map {|r, index|
    remaining_size = @cols.size - r.reduce(&:+)
    gaps = generate_gaps(remaining_size, r, 0, @grid[index])
    puts "Row: #{index}, Gap Count: #{gaps.size}"
    find_overlap(gaps, r)
  })
  display_grid @grid

  @grid = merge_grids(@grid, @cols.each_with_index.map{|c, index|
    remaining_size = @rows.size - c.reduce(&:+)
    gaps = generate_gaps(remaining_size, c, 0, @grid.transpose[index])
    puts "Col: #{index}, Gap Count: #{gaps.size}"
    find_overlap(gaps, c)
  }.transpose)
  display_grid @grid
end

def complete? grid
  !grid.any? {|row| row.any? {|col| col == UNKNOWN_SYMBOL}}
end

@old_grid = @grid
until complete? @grid or
  iterate
  break if @old_grid == @grid
  @old_grid = @grid
end
