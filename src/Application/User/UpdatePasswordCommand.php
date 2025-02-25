<?php

declare(strict_types=1);

namespace App\Application\User;

use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\SecurityBundle\Security;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Annotation\Route;

#[AsCommand(name: 'app:update_password', description: 'Hello PhpStorm')]
class UpdatePasswordCommand extends Command
{
    #[Route('/api/change-password', name: 'api_change_password', methods: ['POST'])]
    public function changePassword(
        Request                     $request,
        Security                    $security,
        EntityManagerInterface      $em,
        UserPasswordHasherInterface $passwordHasher
    ): JsonResponse
    {
        $user = $security->getUser();
        if (!$user) {
            return new JsonResponse(['error' => 'Usuario no autenticado'], Response::HTTP_UNAUTHORIZED);
        }

        $data = json_decode($request->getContent(), true);
        $newPassword = $data['password'] ?? null;

        if (!$newPassword || strlen($newPassword) < 6) {
            return new JsonResponse(['error' => 'La contraseña debe tener al menos 6 caracteres'], Response::HTTP_BAD_REQUEST);
        }

        $hashedPassword = $passwordHasher->hashPassword($user, $newPassword);
        $user->setPassword($hashedPassword);
        $em->flush();

        return new JsonResponse(['success' => 'Contraseña cambiada con éxito']);
    }
}
