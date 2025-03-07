<?php

declare(strict_types=1);

namespace App\Application\User;

use App\Domain\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

#[AsCommand(name: 'app:create-user', description: 'Create user by command')]
class CreateUserCommand extends Command
{
    public function __construct(
        private EntityManagerInterface      $em,
        private UserPasswordHasherInterface $passwordHasher
    )
    {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->addArgument('email', InputArgument::REQUIRED, 'Email del usuario')
            ->addArgument('password', InputArgument::REQUIRED, 'Contraseña del usuario');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $email = $input->getArgument('email');
        $password = $input->getArgument('password');

        // Verificar si el usuario ya existe
        $userRepository = $this->em->getRepository(User::class);
        if ($userRepository->findOneBy(['email' => $email])) {
            $output->writeln("<error>El usuario con email '$email' ya existe.</error>");
            return Command::FAILURE;
        }

        $user = new User();
        $user->setEmail($email);
        $user->setPassword($this->passwordHasher->hashPassword($user, $password));
        $user->setRoles(['ROLE_USER']);

        $this->em->persist($user);
        $this->em->flush();

        $output->writeln("<info>Usuario '$email' creado con éxito.</info>");
        return Command::SUCCESS;
    }
}
