module Rglossa
  module Speech
    module SearchEngines
      class SpeechCwbSearchesController < Rglossa::SearchEngines::CwbSearchesController

        # Used by the base controller to find the right kind of model to work with
        def model_class
          SpeechCwbSearch
        end

        def geo_distr
          search = model_class.find(params[:id])
          distribution = search.geo_distr
          render json: distribution
        end

        ########
        private
        ########

        def transform_result_pages(pages)
          corpus = get_corpus_from_query
          starttime_attr = 'sync_time'
          endtime_attr   = 'sync_end'
          speaker_attr   = 'who_name'
          if corpus.extra_cwb_attrs.include? '+who_line_key'
            line_key_attr = 'who_line_key'
          else
            line_key_attr = nil
          end

          new_pages = {}
          pages.each do |page_no, page|
            line_keys = line_key_attr ? Set.new : nil

            new_pages[page_no] = page.map do |result|
              lines = []
              starttimes = []
              endtimes = []
              displayed_lines = []
              speakers = []
              overall_starttime = nil
              overall_endtime = nil
              line_key = nil

              # If the matching word/phrase is at the beginning of the segment, CQP puts the braces
              # marking the start of the match before the starting segment tag
              # (e.g. {{<turn_endtime 38.26><turn_starttime 30.34>went/go/PAST>...). Probably a
              # bug in CQP? In any case we have to fix it by moving the braces to the
              # start of the segment text instead. Similarly if the match is at the end of a segment.
              result.gsub!(/{{((?:<\S+?\s+?\S+?>\s*)+)/, '\1{{') # find start tags with attributes (i.e., not the match)
              result.gsub!(/((?:<\/\S+?>\s*)+)}}/, '}}\1')        # find end tags

              result.scan(/<#{starttime_attr}\s+([\d\.]+)><#{endtime_attr}\s+([\d\.]+)>(.*?)<\/#{endtime_attr}><\/#{starttime_attr}>/) do |m|
                starttime, endtime, line = m

                overall_starttime ||= starttime
                overall_endtime     = endtime

                line.scan(/<#{speaker_attr}\s+(.+?)>(.*?)<\/#{speaker_attr}>/) do |m2|
                  speakers << m2[0]

                  l = m2[1]
                  if line_key_attr
                    l.sub!(/^<#{line_key_attr}\s+(\d+)>(.*)<\/#{line_key_attr}>/, '\2')
                    # All line keys within the same result should point to the same media file,
                    # so it doesn't matter if we assign this several times for the same result
                    line_key = $1
                  end
                  lines << l
                  # Repeat the start and end time for each speaker within the same segment
                  starttimes << starttime
                  endtimes   << endtime
                end
                # Add the line key found for this result to the set of line keys for this result page
                line_keys << line_key if line_key

                # We asked for a context of several units to the left and right of the unit containing
                # the matching word or phrase, but only the unit with the match (marked by angle
                # brackets) should be included in the search result shown in the result table.
                if line =~ /{{.+}}/
                  # Remove line key attribute tags, since they would only confuse the client code
                  displayed_lines << line.gsub(/<\/?#{line_key_attr}.*?>/, '')
                end
              end

              displayed_lines_str = displayed_lines.join
              if line_key
                # Only add a media object to the data returned to the client if the corpus contains
                # line keys that we can use to determine which media file to show for each result
                media_obj = create_media_obj(overall_starttime, overall_endtime,
                                             starttimes, endtimes, lines, speakers, corpus, line_key)
                {
                    text: displayed_lines_str,
                    media_obj: media_obj,
                    line_key: line_key
                }
              else
                {
                    text: displayed_lines_str
                }
              end
            end

            # Now that all results in this page have been processed, we have a set of line keys
            # (one for each result). Find out how they map to media file names and put the name
            # as a property on the media object that is returned to the client.
            if line_key_attr && line_keys.present?
              conn = ActiveRecord::Base.connection

              ActiveRecord::Base.transaction do
                conn.execute("CREATE TEMPORARY TABLE line_keys (line_key INTEGER)")
                conn.execute("INSERT INTO line_keys " + line_keys.map{|i| "SELECT %d" % i}.join(" UNION "))
                basenames = conn.execute("SELECT line_key, basename FROM line_keys LEFT JOIN rglossa_media_files
                                          ON line_key_begin <= line_key AND line_key <= line_key_end
                                          WHERE corpus_id = %d" % corpus.id).reduce({}) do |m, f|
                  m[f[0]] = f[1]
                  m
                end
                conn.execute("DROP TABLE line_keys")

                new_pages[page_no].map! do |result|
                  result[:media_obj][:mov][:movie_loc] = basenames[result[:line_key].to_i]
                  result
                end
              end
            end
          end

          new_pages
        end

        # Creates the data structure that is needed by jPlayer for a single search result
        def create_media_obj(overall_starttime, overall_endtime,
            starttimes, endtimes, lines, speakers, corpus, line_key)
          word_attr = 'word' # TODO: make configurable?
          obj = {
              title: '',
              last_line: lines.size - 1,
              display_attribute: word_attr,
              corpus_id: corpus.id,
              mov: {
                  supplied: 'm4v',
                  path: corpus.media_path || "media/#{corpus.short_name}",
                  line_key: line_key,
                  start: overall_starttime,
                  stop: overall_endtime
              },
              divs: {
                  annotation: {
                  }
              }
          }
          matching_line_index = nil
          lines.each_with_index do |line, index|
            token_no = -1
            is_match = false
            obj[:divs][:annotation][index] = {
                speaker: speakers.shift || '',
                line: line.split(/\s+/).reduce({}) do |acc, token|
                  token_no += 1

                  # Note: when matching a phrase, left and right braces will be on different
                  # tokens!
                  if token.match(/^{{(.*)/) || token.match(/(.*)}}$/)
                    is_match = true
                    matching_line_index = index
                    token.sub!(/^{{/, '')
                    token.sub!(/}}$/, '')
                  end
                  attr_values = token.split('/')
                  acc[token_no] = Hash[[word_attr].concat(corpus.display_attrs).zip(attr_values)]
                  acc
                end,
                from: starttimes.shift,
                to: endtimes.shift
            }
            obj[:divs][:annotation][index][:is_match] = is_match
          end
          obj[:start_at] = matching_line_index
          obj[:end_at]   = matching_line_index
          obj[:min_start] = 0
          obj[:max_end] = lines.size - 1
          obj
        end

      end
    end
  end
end
