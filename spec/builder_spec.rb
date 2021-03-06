# frozen_string_literal: true

require_relative '../lib/surrealist'

class Table
  include Surrealist

  def foo
    'A string'
  end

  def bar
    [1, 2, 4]
  end

  def baz
    { key: :value }
  end
end

RSpec.describe Surrealist::Builder do
  subject(:result) { described_class.call(schema, instance) }

  let(:instance) { Table.new }

  context 'valid schema is passed' do
    let(:schema) { Hash[foo: String, bar: Array] }

    it 'returns hash with correct values' do
      is_expected.to eq(foo: 'A string', bar: [1, 2, 4])
    end

    context 'with hash as a type' do
      let(:schema) { Hash[foo: String, baz: Hash] }

      it 'returns hash with correct values' do
        is_expected.to eq(foo: 'A string', baz: { key: :value })
      end
    end

    context 'with nested values' do
      let(:schema) { Hash[foo: String, nested: { bar: Array, again: { baz: Hash } }] }

      it 'returns hash with correct values' do
        is_expected.to eq(foo: 'A string', nested: { bar: [1, 2, 4], again: { baz: { key: :value } } })
      end
    end
  end

  context 'invalid schema is passed' do
    context 'with undefined method' do
      let(:schema) { Hash[not_a_method: String] }
      let(:message) { /undefined method `not_a_method'.* You have probably defined a key in the schema that doesn't have a corresponding method/ } # rubocop:disable Metrics/LineLength

      it 'raises UndefinedMethodError' do
        expect { result }.to raise_error(Surrealist::UndefinedMethodError, message)
      end
    end

    context 'with invalid types' do
      let(:schema) { Hash[foo: Integer, bar: String] }

      it 'raises TypeError' do
        expect { result }
          .to raise_error(TypeError, 'Wrong type for key `foo`. Expected Integer, got String.')
      end
    end
  end
end
