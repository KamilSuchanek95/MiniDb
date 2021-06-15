#### MiniDb - simple in-memory database
- This is just an exercise, there is no point in using it
- This works on only variables.
- Support for nested transaction.

  - The transaction mechanism consists in saving the operations as lambda objects, which result in the reversal of the introduced changes in the case of rejection of the performed actions.

#### How to run?
- open terminal in MiniDb folder,
  - type `rspec` for run tests,
  - type `ruby main.rb` for run example script with usages
