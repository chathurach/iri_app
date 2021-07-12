import 'dart:math';

//calculate the IRI value based on VALIDATION OF SMARTPHONE-BASED PAVEMENT ROUGHNESS MEASURES
//by FIROOZI YEGANEH S., MAHMOUDZADEH A., AZIZPOUR M.A., GOLROO A.*
//https://www.sid.ir/en/Journal/ViewPaper.aspx?ID=600013
double iriCalc(List<double> z) {
  double iri = 0.0;
  double rms = 0.0;
  print(z);
  for (int i = 0; i < z.length - 1; i++) {
    rms += (pow(z[i], 2)).toDouble();
  }
  //print('rms: $rms');
  rms = sqrt(rms / z.length);

  iri = 4.19 * rms + 1.73;
  return iri;
}
