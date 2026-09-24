# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { create(:user) }

    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(30) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to allow_value("valid_name", "user_123").for(:username) }
    it { is_expected.not_to allow_value("Invalid Name", "spaces here").for(:username) }
  end

  describe "username normalization" do
    it "normalizes username before validation" do
      user = build(:user, username: "  Mixed_Name  ")

      expect(user).to be_valid
      expect(user.username).to eq("mixed_name")
    end
  end

  describe "username validation" do
    it "rejects invalid username format" do
      user = build(:user, username: "Invalid Name")

      expect(user).not_to be_valid
      expect(user.errors[:username]).to include(I18n.t("devise.errors.messages.username_format"))
    end
  end

  describe "subscription limits" do
    let(:user) { create(:user) }

    describe "#can_send_prompt?" do
      it "returns false when user has no subscription_plan" do
        user.update!(subscription_plan: nil, subscription_period_started_at: nil, subscription_period_ends_at: nil)
        expect(user.can_send_prompt?).to be(false)
      end

      it "returns true when user has active plan and under limits" do
        user.update!(
          subscription_plan: "starter",
          subscription_period_started_at: 1.day.ago,
          subscription_period_ends_at: 1.month.from_now
        )
        expect(user.can_send_prompt?).to be(true)
      end

      it "returns false when period has ended" do
        create(:user, :expired_subscription).tap do |u|
          expect(u.can_send_prompt?).to be(false)
        end
      end
    end

    describe "#tokens_used_this_period" do
      it "returns 0 when no period" do
        user.update!(subscription_plan: nil, subscription_period_started_at: nil, subscription_period_ends_at: nil)
        expect(user.tokens_used_this_period).to eq(0)
      end
    end
  end

  describe ".created_in_last" do
    it "returns users created within the given days" do
      u1 = create(:user, created_at: 5.days.ago)
      u2 = create(:user, created_at: 15.days.ago)
      create(:user, created_at: 31.days.ago)

      result = described_class.created_in_last(days: 30)

      expect(result).to include(u1, u2)
      expect(result.count).to eq(2)
    end

    it "excludes users older than the given days" do
      create(:user, created_at: 31.days.ago)

      expect(described_class.created_in_last(days: 30).count).to eq(0)
    end
  end
end
