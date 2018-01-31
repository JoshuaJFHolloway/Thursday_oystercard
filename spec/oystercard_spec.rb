require 'oystercard'

describe Oystercard do

  subject(:card) { described_class.new }

  let(:station) { double "a station" }

  let(:card_touched_in) do
    card.top_up(10)
    card.touch_in(station)
    card
  end

  describe 'balance' do
    it 'when initialized has a balance of 0' do
      expect(card.balance).to be_zero
    end

    it 'raises error when Oystercard balance is greater than 90 pounds' do
      balance_limit = Oystercard::BALANCE_LIMIT
      card.top_up(balance_limit)
      message = "Error - maximum balance is #{balance_limit} pounds"
      expect { card.top_up(1) }.to raise_error(message)
    end
  end

  describe '#touch in' do

    it {is_expected.to respond_to(:touch_in).with(1).argument}

    it 'changes status to true' do
      expect(card_touched_in).to be_in_journey
    end

    it 'prevents touching in when balance is below one pound' do
      minimum_balance = Oystercard::BALANCE_MIN
      message = "Insufficient funds - minimum balance is #{minimum_balance}"
      expect { card.touch_in(station) }.to raise_error message
    end

    it 'correctly stores the entry station' do
      expect(card_touched_in.entry_station).to eq station
    end
  end

  describe '#touch out' do

    it 'changes status to false' do
      card_touched_in.touch_out
      expect(card_touched_in).not_to be_in_journey
    end

    it 'deducts the minimum fare' do
      card_touched_in
      expect { card_touched_in.touch_out }.to change { card.balance }.by(-Oystercard::MIN_CHARGE)
    end

    it 'changes entry station to nil after journey' do
      card_touched_in.touch_out
      expect(card_touched_in.entry_station).to be_nil
    end

  end

  describe '#top_up' do
    it 'adjusts balance by top up amount' do
      expect { card.top_up(1) }.to change { card.balance }.by(1)
    end
  end
end
