<?php

namespace App\Domain\Validation;

use App\Domain\Entity\Category;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Validator\Constraint;
use Symfony\Component\Validator\ConstraintValidator;

class UniqueCategoryNameValidator extends ConstraintValidator
{

    public function __construct(private EntityManagerInterface $entityManager) {}

    public function validate($value, Constraint $constraint)
    {
        if (null === $value || '' === $value) {
            return;
        }

        $existingCategory = $this->entityManager->getRepository(Category::class)->findOneBy(['name' => $value]);

        if ($existingCategory) {
            $this->context->buildViolation($constraint->message)
                ->setParameter('{{ name }}', $value)
                ->addViolation();
        }
    }
}