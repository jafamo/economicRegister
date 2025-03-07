<?php

namespace App\Infrastructure\Symfony\Form\DataTransformer;

use ApiPlatform\Metadata\UriVariableTransformerInterface;
use App\Domain\Entity\Category;
use Doctrine\ORM\EntityManagerInterface;

class CategoryInputDataTransformer implements UriVariableTransformerInterface
{

    private EntityManagerInterface $entityManager;

    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
    }

    public function transform($data, string|array $types, array $context = [])
    {
        if (isset($data['parent']) && is_numeric($data['parent'])) {
            $data['parent'] = $this->entityManager->getReference(Category::class, $data['parent']);
        }

        return $data;
    }

    public function supportsTransformation($data, string|array $types, array $context = []): bool
    {
        return $types === Category::class && is_array($data);
    }
}