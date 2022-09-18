require 'rails_helper'

RSpec.describe User, type: :model do
    describe(".name") do
        it "validates presence" do
            user = User.new(email:"01@test.io",password:"password")
            expect(user.valid?).to be_falsy
            expect(user.errors.full_messages).to eq(["名前を入力してください"])
        end
        it "does not accept name over 30 characters" do
            max = 30
            name = "a" * (max + 1)
            user = User.new(name:name, email:"01@test.io",password:"password")
            expect(user.valid?).to be_falsy
            expect(user.errors.full_messages).to eq(["名前は30文字以内で入力してください"])
        end
        it "accepts name within 30 characters" do
            max = 30
            name = "a" * max
            user = User.new(name:name, email:"01@test.io",password:"password")
            expect{user.save}.to change{User.count}.from(0).to(1)
        end
    end
    describe ".email" do
        it "does not accept email over 30 characters" do
            max = 255
            domain = "@test.io"
            email = "a" * (max + 1 - domain.length) + domain
            user = User.new(name:"test",email:email,password:"password")
            expect(user.valid?).to be_falsy
            expect(user.errors.full_messages).to eq(["メールアドレスは255文字以内で入力してください"])
        end
        it "accepts email within 30 characters" do
            max = 255
            domain = "@test.io"
            email = "a" * (max - domain.length) + domain
            user = User.new(name:"test",email:email,password:"password")
            expect{user.save}.to change{User.count}.from(0).to(1)
        end
        it "accepts proper email" do
            count = User.count
            ok_emails = %w(
                A@EX.COM
                a-_@e-x.c-o_m.j_p
                a.a@ex.com
                a@e.co.js
                1.1@ex.com
                a.a+a@ex.com
              )
            ok_emails.each do |ok_email|
                user = User.new(name:"test", email:ok_email,password:"password")
                expect(user.valid?).to be_truthy
            end
        end
        it "does not accept improper email" do
            ng_emails = %w(
                aaa
                a.ex.com
                メール@ex.com
                a~a@ex.com
                a@|.com
                a@ex.
                .a@ex.com
                a＠ex.com
                Ａ@ex.com
                a@?,com
                １@ex.com
                "a"@ex.com
                a@ex@co.jp
            )
            ng_emails.each do |ng_email|
                user = User.new(name:"test", email:ng_email,password:"password")
                expect(user.valid?).to be_falsy
            end
        end
        it "downcases email" do
            uppercase_email = "UPPERCASE@TEST.IO"
            user = User.new(email:uppercase_email)
            user.save
            expect(user.email).to eq(uppercase_email.downcase)
        end
        it "accepts two users with same email if not activated" do
            user1 = User.new(name:"test",email:"01@test.io",password:"password",activated:false)
            user1.save
            user2 = User.new(name:"test",email:"01@test.io",password:"password",activated:false)
            expect(user2.valid?).to be_truthy
        end
        it "does not accept two users with same email if activated" do
            user1 = User.new(name:"test",email:"01@test.io",password:"password",activated:true)
            user1.save
            user2 = User.new(name:"test",email:"01@test.io",password:"password",activated:false)
            user2.save
            expect(user2.errors.full_messages).to eq(["メールアドレスはすでに存在します"])
        end
        it "accepts two users with same email if first user is destroyed" do
            user1 = User.new(name:"test",email:"01@test.io",password:"password",activated:true)
            user1.save
            user1.destroy
            user2 = User.new(name:"test",email:"01@test.io",password:"password",activated:true)
            expect(user2.valid?).to be_truthy
        end
    end
    describe ".password" do
        it "accepts password with within 72 characters" do
            max = 72
            password = "a" * max
            user = User.new(name:"test",email:"01@test.io",password:password)
            expect(user.valid?).to be_truthy
        end
        it "does not accept password with over 72 characters" do
            max = 72
            password = "a" * (max + 1)
            user = User.new(name:"test",email:"01@test.io",password:password)
            expect(user.valid?).to be_falsy
            expect(user.errors.full_messages).to eq(["パスワードは72文字以内で入力してください"])
        end
        it "accepts password with more than 7 characters" do
            min = 7
            password = "a" * (min + 1)
            user = User.new(name:"test",email:"01@test.io",password:password)
            expect(user.valid?).to be_truthy
        end
        it "does not accept password with less than 8 characters" do
            min = 7
            password = "a" * min
            user = User.new(name:"test",email:"01@test.io",password:password)
            expect(user.valid?).to be_falsy
            expect(user.errors.full_messages).to eq(["パスワードは8文字以上で入力してください"])
        end
    end
end