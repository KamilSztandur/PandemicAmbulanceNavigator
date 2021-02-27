class InputParsingException implements Exception {
  const InputParsingException(this.line);

  final String line;
}

class HospitalParsingException extends InputParsingException {
  HospitalParsingException(String line) : super(line);
}

class PlaceParsingException extends InputParsingException {
  PlaceParsingException(String line) : super(line);
}

class RoadParsingException extends InputParsingException {
  RoadParsingException(String line) : super(line);
}

class PatientParsingException extends InputParsingException {
  PatientParsingException(String line) : super(line);
}
