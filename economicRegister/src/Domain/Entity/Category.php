<?php

namespace App\Domain\Entity;

use ApiPlatform\Metadata\ApiResource;
use Symfony\Component\Validator\Constraints as Assert;
use App\Domain\Validation\UniqueCategoryName;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
#[ORM\Table(name: "categories", uniqueConstraints: [
    new ORM\UniqueConstraint(name: "unique_category_per_parent", columns: ["name", "parent_id"])
])]
#[ApiResource(
    formats: ['json' => 'application/json', 'jsonld' => 'application/ld+json', 'jsonapi' => 'application/vnd.api+json']
)]
class Category
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: "integer")]
    private ?int $id = null;

    #[Assert\NotBlank]
    #[UniqueCategoryName]
    #[ORM\Column(type: "string", length: 255)]
    private string $name;

    #[ORM\ManyToOne(targetEntity: self::class, inversedBy: "children")]
    #[ORM\JoinColumn(name: "parent_id", referencedColumnName: "id", onDelete: "SET NULL", nullable: true)]
    private ?Category $parent = null;

    #[ORM\OneToMany(mappedBy: "parent", targetEntity: self::class, cascade: ["persist", "remove"])]
    private ?Collection $children;

    public function __construct(string $name, ?Category $parent = null)
    {
        $this->name = $name;
        $this->parent = $parent;
        $this->children = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): self
    {
        $this->name = $name;
        return $this;
    }

    public function getParent(): ?Category
    {
        return $this->parent;
    }

    public function setParent(?Category $parent): self
    {
        $this->parent = $parent;
        return $this;
    }

    /**
     * @return Collection<int, Category>
     */
    public function getChildren(): Collection
    {
        return $this->children;
    }

    public function addChild(Category $child): self
    {
        if (!$this->children->contains($child)) {
            $this->children->add($child);
            $child->setParent($this);
        }
        return $this;
    }

    public function removeChild(Category $child): self
    {
        if ($this->children->removeElement($child)) {
            if ($child->getParent() === $this) {
                $child->setParent(null);
            }
        }
        return $this;
    }
}