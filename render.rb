require "bundler/setup"
require "ecfs"
require "sharpie"
require "digest/md5"
require "pry"
require "json"
require "markaby"
require "rack-linkify"

def md5_from_filing(filing)
  f = filing
  string = f["docket_number"] + f["type_of_filing"] + f["name_of_filer"] + f["date_posted"] + f["date_received"] + f["document_urls"].join(",")
  Digest::MD5.hexdigest(string)
end

def array_of_hashes_to_table(array_of_hashes)
  mab = Markaby::Builder.new
  mab.html do
    body do
      table do
        tr do
          for k in array_of_hashes.first.keys
            th k
          end 
        end
        for f in array_of_hashes
          tr do
            for k in array_of_hashes.first.keys
              td f[k]
            end
          end
        end
      end
    end
  end

  mab.to_s
end

class App < Sharpie::Base
  use Rack::Linkify

  def self.get_comments(docket_number)
    ECFS::Filing.query.tap do |q|
      q.submission_type_id = "7"
      q.docket_number = docket_number
    end.get
  end

  def self.get_proceeding(docket_number)
    ECFS::Proceeding.find(docket_number)
  end

  def self.docket_numbers
    [
      "13-5",
      "12-268",
      "12-375"
    ]
  end

  docket_numbers.each do |docket_number|

    proceeding = get_proceeding(docket_number)
    comments   = get_comments(docket_number)

    comments.each do |comment| 
      comment["id"] = md5_from_filing(comment)
    end

    get "/proceedings/#{docket_number}.json" do
      content_type "application/json"
      proceeding.to_json
    end

    get "/proceedings/#{docket_number}" do
      array_of_hashes_to_table([proceeding])
    end

    get "/proceedings/#{docket_number}/comments.json" do
      content_type "application/json"
      {
        "results" => comments
      }.to_json
    end

    get "/proceedings/#{docket_number}/comments" do
      array_of_hashes_to_table(comments)
    end

    comments.each do |comment|
      get "/proceedings/#{docket_number}/comments/#{comment['id']}.json" do
        content_type "application/json"
        comment.to_json
      end

      get "/proceedings/#{docket_number}/comments/#{comment['id']}" do
        array_of_hashes_to_table([comment])
      end
    end

  end
end

App.build!("_site")