# encoding: utf-8
namespace :admin do
  namespace :users do
    
    desc "Manage Massive Users by command line"
    task :manage => :environment do
      users = parse_users_cli
      print_table_user(users)

      puts "\nPerform operations in DB??? [y,N]"

      perform_it = STDIN.gets.strip
      if perform_it.downcase == 'y'
        users.each do |user|
          if user.save
            puts "user #{ user.login } save / update"
          else
            puts "user #{ user.login } hash errors. #{ user.errors.inspect }"
          end
        end
      else
        puts "Admin didnt answer yes. Aborted!\n"
      end
      puts "done =)"
    end


    private
    def parse_users_cli
      user_attributes = ARGV[1..-1]
      user_attributes.inject([]) do |users, user_attributes|
        attributes = parse_attributes(user_attributes)
        if valid_user_attributes(attributes)
          u = User.find_by_login(attributes['login']) || User.new
          u.login              = attributes['login']
          u.email                 = attributes['email']
          u.password              = attributes['password']
          u.password_confirmation = attributes['password']
          if u.valid?
            users << u
          else
            raise " ***** User #{ u.login } is not valid. #{ u.errors.inspect }"
          end
        else
          raise 'Invalid attributes in command line. Use format "login=user_login_1,email=user_email_1,password=user_pass_1" "login=user_login_2,email=user_email_2,password=user_pass_2"'
        end
      end
    end

    def parse_attributes(user_attributes)
      attrs = user_attributes.split(',')
      hash = attrs.inject({}) do |user_hash, attr|
        user_hash[attr.split('=').first] = attr.split('=').last
        user_hash
      end
    end

    def valid_user_attributes(attributes)
      attributes.keys.sort == ['email', 'login', 'password']
    end

    def print_table_user(users)
      puts "\n\n The next actions actions will be executed\n"
      users.each do |user|
        if user.new_record?
          puts "   » Create new User with login #{ user.login }, email #{ user.email } and password => #{ user.password }"
        else
          if user.changed?
            puts "   » Update user #{ user.id }. Fields changed are: #{ user.changes.map{ |k,v| "#{ k } to #{ v.last }" }.join(',') } and password to #{ user.password }"
          else
            puts "   » Update user #{ user.id }, only password will be set to #{ user.password }"
          end
        end
      end
    end

  end
end
