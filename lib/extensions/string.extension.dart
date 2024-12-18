import 'package:intl/intl.dart';

class MRZData {
  String givenNames;
  String surname;
  DateTime? dateOfBirth;

  String issuingCountry;
  String passportNumber;
  String nationality;
  String sex;
  DateTime? expiryDate;
  String optionalData;
  String compositeCheckDigit;

  MRZData({
    required this.issuingCountry,
    required this.surname,
    required this.givenNames,
    required this.passportNumber,
    required this.nationality,
    required this.dateOfBirth,
    required this.sex,
    required this.expiryDate,
    required this.optionalData,
    required this.compositeCheckDigit,
  });

  @override
  String toString() {
    return 'Issuing Country: $issuingCountry\n'
        'Surname: $surname\n'
        'Given Names: $givenNames\n'
        'Passport Number: $passportNumber\n'
        'Nationality: $nationality\n'
        'Date of Birth: ${dateOfBirth != null ? DateFormat('yyyy-MM-dd').format(dateOfBirth!) : null}\n'
        'Sex: $sex\n'
        'Expiry Date: ${expiryDate != null ? DateFormat('yyyy-MM-dd').format(expiryDate!) : null}\n'
        'Optional Data: $optionalData\n'
        'Composite Check Digit: $compositeCheckDigit';
  }

  static MRZData? extractMRZfromString(String recognizedText) {
    final lines = recognizedText.split('\n');
    if (lines.length < 2) return null;

    for (int i = 0; i < lines.length - 1; i++) {
      if (lines[i].length == 44 && lines[i + 1].length == 44) {
        return parseMRZ("${lines[i]}\n${lines[i + 1]}");
      }
    }
    return null;
  }

  static DateTime? _parseMRZDate(String dateString) {
    try {
      final year = int.parse(dateString.substring(0, 2));
      final month = int.parse(dateString.substring(2, 4));
      final day = int.parse(dateString.substring(4, 6));

      // Adjust year based on the current century (assuming passports don't last more than 100 years)
      final currentYear = DateTime.now().year % 100;
      final century = DateTime.now().year - currentYear;
      final fullYear = year > currentYear + 10 ? century - 100 + year : century + year;

      return DateTime(fullYear, month, day);
    } catch (e) {
      return null;
    }
  }

  static MRZData? parseMRZ(String mrzString) {
    print(mrzString);
    // Split the MRZ into two lines
    final lines = mrzString.split('\n');
    if (lines.length != 2) {
      return null;
    }

    final line1 = lines[0];
    final line2 = lines[1];

    if (line1.length != 44 || line2.length != 44) {
      return null;
    }

    try {
      final documentType = line1.substring(0, 1);
      if (documentType != 'P') return null;
      final issuingCountry = line1.substring(2, 5);
      final namePart = line1.substring(5).split('<<');
      final surname = namePart[0];
      final givenNames = namePart.length > 1 ? namePart[1].replaceAll('<', ' ').trim() : '';

      final passportNumber = line2.substring(0, 9);
      final nationality = line2.substring(10, 13);
      final dobString = line2.substring(13, 19);
      final sex = line2.substring(20, 21);
      final expiryDateString = line2.substring(21, 27);
      final optionalData = line2.substring(27, 43);
      final compositeCheckDigit = line2.substring(43, 44);

      final dob = _parseMRZDate(dobString);
      final expiryDate = _parseMRZDate(expiryDateString);

      return MRZData(
        issuingCountry: issuingCountry,
        surname: surname,
        givenNames: givenNames,
        passportNumber: passportNumber,
        nationality: nationality,
        dateOfBirth: dob,
        sex: sex,
        expiryDate: expiryDate,
        optionalData: optionalData,
        compositeCheckDigit: compositeCheckDigit,
      );
    } catch (e) {
      return null;
    }
  }
}
