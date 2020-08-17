class CreditCard {
  String _number;
  String _dueMonth;
  String _dueYear;
  String _ccv;

  CreditCard(this._number, this._dueMonth, this._dueYear, this._ccv);

  String get ccv => _ccv;

  String get dueYear => _dueYear;

  String get dueMonth => _dueMonth;

  String get number => _number;
}
