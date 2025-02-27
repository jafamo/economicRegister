<?php

namespace App\Domain\Validation;

use Symfony\Component\Validator\Constraint;

#[\Attribute]
class UniqueCategoryName extends Constraint
{
    public string $message = 'La categoría "{{ name }}" ya existe.';

    public function validatedBy(): string
    {
        return UniqueCategoryNameValidator::class;
    }
}