double imcCalculator(double weight, double height) {
  double imc = weight / (height * height);
  return imc;
}

String imcStatusLogic(double imc) {
  var imcStatus = '';

  // Clasificar estado del IMC
  if (imc < 18.5) {
    imcStatus = 'Bajo Peso';
  } else if (imc < 22.9) {
    imcStatus = 'Normal';
  } else if (imc < 24.9) {
    imcStatus = 'Sobrepeso';
  } else {
    imcStatus = 'Obesidad';
  }

  return imcStatus;
}
