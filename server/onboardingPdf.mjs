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

    pdf.text(
      `Demandeur : ${data.requesterName || '-'}`
    );

    pdf.text(
      `Email : ${data.requesterEmail || '-'}`
    );

    pdf.moveDown();

    pdf.text(
      `Collaborateur : ${data.firstName} ${data.lastName}`
    );

    pdf.text(
      `Fonction : ${data.jobTitle || '-'}`
    );

    pdf.text(
      `Date d'arrivée : ${data.effectiveDate || '-'}`
    );

    pdf.moveDown();

    pdf.text(
      `Contrat : ${data.contractType || '-'}`
    );

    pdf.text(
      `Statut : ${data.employeeStatus || '-'}`
    );

    pdf.text(
      `Niveau : ${data.employeeLevel || '-'}`
    );

    pdf.text(
      `Salaire : ${data.grossAnnualSalary || '-'}`
    );

    pdf.text(
      `Prime variable : ${data.variableBonus || '-'}`
    );

    pdf.moveDown();

    pdf.text(
      `École : ${data.school || '-'}`
    );

    pdf.text(
      `Mission : ${data.internshipMission || '-'}`
    );

    pdf.moveDown();

    pdf.text(
      `Boites partagées :`
    );

    pdf.text(
      data.sharedMailboxes || '-'
    );

    pdf.end();

    stream.on('finish', resolve);
    stream.on('error', reject);
  });

  return {
    fileName,
    filePath
  };
}
