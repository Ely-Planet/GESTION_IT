import fs from 'fs';
import path from 'path';
import PDFDocument from 'pdfkit';

export async function generateOnboardingPdf(data) {
  const fileName =
    `Onboarding_${Date.now()}.pdf`;

  const filePath = path.join(
    process.cwd(),
    'storage/onboarding',
    fileName
  );

  await new Promise((resolve, reject) => {
    const pdf = new PDFDocument({
      size: 'A4',
      margin: 50
    });

    const stream = fs.createWriteStream(filePath);

    pdf.pipe(stream);

pdf.image(
  path.join(
    process.cwd(),
    'public/assets/logo-elyade.png'
  ),
  40,
  25,
  {
    width: 60
  }
);

pdf.y = 90;

    pdf
      .fontSize(18)
      .text(
        "DEMANDE D'ONBOARDING",
        {
          align: 'center'
        }
      );

    pdf.moveDown();

    pdf.fontSize(12);

    pdf.font('Helvetica-Bold')

    .text(
      `Demandeur : ${data.requesterName || '-'}`
    );

    pdf.font('Helvetica')
    .text(
      `Email : ${data.requesterEmail || '-'}`
    );

pdf.moveDown();

 pdf.font('Helvetica')
    .text(
      `-------------------------------------------------`
    );


    pdf.moveDown();

    pdf.font('Helvetica')
.text(
      `Collaborateur : ${data.firstName} ${data.lastName}`
    );

    pdf.font('Helvetica')
.text(
      `Fonction : ${data.jobTitle || '-'}`
    );

if (
  Array.isArray(data.services) &&
  data.services.length > 0
) {
  for (const service of data.services) {
    pdf.font('Helvetica')
pdf.text(
  `• ${service.replace('🏢', '')}`
);
  }
} else {
  pdf.font('Helvetica')
.text('Aucun service');
}

    pdf.font('Helvetica')
.text(
      `Date d'arrivée : ${data.effectiveDate || '-'}`
    );

    pdf.moveDown();
 pdf.font('Helvetica')
    .text(
      `-------------------------------------------------`
    );
pdf.moveDown();



    pdf.font('Helvetica')
.text(
      `Contrat : ${data.contractType || '-'}`
    );

    pdf.font('Helvetica')
.text(
      `Statut : ${data.employeeStatus || '-'}`
    );

    pdf.font('Helvetica')
.text(
      `Niveau : ${data.employeeLevel || '-'}`
    );


pdf.font('Helvetica')
.text(
  `Véhicule de fonction : ${
    data.companyCar ? 'Oui' : 'Non'
  }`
);


pdf.font('Helvetica')
.text(
  `Salaire : ${ data.grossAnnualSalary ? `${data.grossAnnualSalary} €` : '-' }`
);

pdf.font('Helvetica')
.text(
  `Prime variable : ${
    data.variableBonus
      ? `${data.variableBonus} €`
      : '-'
  }`
);

    pdf.font('Helvetica')
.text(
      `École : ${data.school || '-'}`
    );

    pdf.font('Helvetica')
.text(
      `Mission : ${data.internshipMission || '-'}`
    );

pdf.moveDown();

 pdf.font('Helvetica')
    .text(
      `-------------------------------------------------`
    );
pdf.moveDown();
pdf.font('Helvetica')
.text(
  `Cooptation : ${
data.referralEmployee
  ? 'Oui'
  : 'Non'  }`
);

pdf.font('Helvetica')
.text(
  `Collaborateur référent : ${data.referralEmployee || '-'}`
);

    pdf.moveDown();


    pdf.end();

    stream.on('finish', resolve);
    stream.on('error', reject);
  });

  return {
    fileName,
    filePath
  };
}
